"""Offline profile regression tests. All writable state is under a fresh /tmp HOME."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
ZSH = shutil.which('zsh')
BASH = shutil.which('bash')
PYTHON = shutil.which('python3')

# No mock delegates to a real network, package manager, login shell or chsh.
MOCK = r'''#!PYTHON
import json, os, pathlib, shutil, sys
p = pathlib.Path
name, args = p(sys.argv[0]).name, sys.argv[1:]
with open(os.environ['CALLS'], 'a') as f: f.write(json.dumps([name, args])+'\n')
fail = os.environ.get('FAIL', '')
def fixture(dest):
    dest.mkdir(parents=True, exist_ok=True)
    (dest/'install_awesome_vimrc.sh').write_text('exit 0\n')
    (dest/'custom').mkdir(exist_ok=True)
if name == 'wget':
    url=args[-1]
    if fail == 'download' or (fail == 'primary' and 'raw.githubusercontent.com/LynnHo' in url): sys.exit(9)
    if fail == 'aux' and ('hfd.sh' in url or 'lesspipe' in url): sys.exit(9)
    if fail == 'fzf' and 'fzf/releases' in url: sys.exit(9)
    if fail == 'fzf-primary' and url.startswith('https://github.com/junegunn/fzf/releases'): sys.exit(9)
    target=args[args.index('-O')+1]
    if target != '-':
        text = url+'\n'
        if target.endswith('miniforge.sh'): text = os.environ['MINIFORGE']
        p(target).write_text(text)
elif name == 'tar':
    if '-C' in args:
        (p(args[args.index('-C')+1])/'fzf').write_text('mock fzf\n')
elif name == 'git':
    if args[0] == 'clone':
        dest=p(args[-1]); fixture(dest)
        if '.Make-Workspace_tmp' in str(dest):
            for n in ['.zshrc','.p10k.zsh','my_configs.vim','.tmux.conf']: (dest/n).write_text('fixture\n')
            (dest/'.ws').mkdir(); (dest/'.ws'/'updated').write_text('ok')
    else: print('0.60.0')
elif name == 'rsync':
    shutil.copytree(args[-2],args[-1],dirs_exist_ok=True)
elif name == 'mamba' or name == 'conda':
    if fail == 'env': sys.exit(8)
elif name == 'mv':
    if fail == 'record' and args[-1].endswith('/.tools_profile'): sys.exit(7)
    shutil.move(args[-2], args[-1])
elif name == 'mktemp':
    if fail == 'mktemp': sys.exit(7)
    import tempfile
    template=args[-1]; fd, path=tempfile.mkstemp(prefix=p(template).name.replace('XXXXXX',''),dir=str(p(template).parent))
    os.close(fd); print(path)
elif name in ['chsh','tmux','tldr','zsh']: pass
else: raise RuntimeError('Unexpected mock '+name)
'''


class Profiles(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='tools-profile-test.', dir='/tmp')
        self.base = Path(self.tmp.name)
        self.home = self.base/'home'; self.home.mkdir()
        self.repo = self.base/'repo'; self.repo.mkdir()
        self.bin = self.base/'bin'; self.bin.mkdir()
        self.ws = self.home/'.ws'; self.ws.mkdir()
        self.profile = self.ws/'.tools_profile'
        self.calls = self.base/'calls'
        self.tools = self.home/'ProgramFiles/anaconda3/envs/tools'
        (self.tools/'bin').mkdir(parents=True)
        self.dispatch = self.base/'mock'; self.dispatch.write_text(MOCK.replace('#!PYTHON', '#!'+PYTHON)); self.dispatch.chmod(0o755)
        for name in ['wget','tar','git','rsync','conda','chsh','tmux','tldr','mv','mktemp']:
            (self.bin/name).symlink_to(self.dispatch)
        # timeout remains real, but its target resolves only to the mocks above.
        self.env = dict(os.environ, HOME=str(self.home), WS=str(self.ws), TOOL_HOME=str(self.tools),
                        PATH=str(self.bin)+':/usr/bin:/bin', CALLS=str(self.calls), FAIL='',
                        GITHUB_PROXY='https://proxy.invalid', ZDOTDIR=str(self.home))
        for key in ['TOOLS_STABLE','BASH_ENV','ENV','ZSH_CUSTOM','CONDA_PREFIX']:
            self.env.pop(key, None)
        source = (ROOT/'.zshrc').read_text()
        self.functions = source[source.index('record_tools_profile()(\n'):source.index('update_all()(\n')]
        self.custom = source[source.index('## customized utils'):source.index('# ==============================================================================',source.index('## customized utils'))]
        self.miniforge = '''#!/bin/bash
set -e
prefix=$3
mkdir -p "$prefix/bin" "$prefix/envs/tools/bin"
printf ':\\n' > "$prefix/bin/activate"
ln -s "$MOCK_DISPATCH" "$prefix/bin/mamba"
for tool in zsh tldr; do ln -s "$MOCK_DISPATCH" "$prefix/envs/tools/bin/$tool"; done
for tool in ping ping6; do touch "$prefix/envs/tools/bin/$tool"; done
'''
        self.env.update(MINIFORGE=self.miniforge, MOCK_DISPATCH=str(self.dispatch))
        for n in ['ping','ping6']: (self.tools/'bin'/n).touch()

    def tearDown(self):
        self.tmp.cleanup()

    def run_shell(self, code, shell=None):
        result = subprocess.run([shell or ZSH, '-f' if shell != BASH else '--noprofile', '-c', code],
                                env=self.env, cwd=self.repo, text=True, capture_output=True, timeout=15)
        return result

    def update(self, fn='update_tools_stable', before='', after=''):
        return self.run_shell(self.functions+'\n'+before+'\n'+fn+'\nresult=$?\n'+after+'\nexit $result')

    def log(self):
        return [json.loads(line) for line in self.calls.read_text().splitlines()] if self.calls.exists() else []

    def yaml_urls(self):
        return [args[-1] for name,args in self.log() if name=='wget' and 'Make-Workspace/' in args[-1]]

    def install(self, script='make_workspace_stable.sh', args=()):
        for name in ['make_workspace_stable.sh','make_workspace_latest.sh','.zshrc','.p10k.zsh','.tmux.conf','my_configs.vim']:
            shutil.copyfile(ROOT/name,self.repo/name)
        (self.repo/'.ws').mkdir(exist_ok=True)
        stable=self.repo/'stable'; stable.mkdir(exist_ok=True)
        for name in ['.vim_runtime','.fzf','.oh-my-zsh']:
            (stable/name).mkdir(exist_ok=True)
        (stable/'.vim_runtime/install_awesome_vimrc.sh').write_text('exit 0\n')
        for name in ['fzf','lesspipe.sh']: (stable/name).write_text('fixture\n')
        return subprocess.run([BASH,str(self.repo/script),*args],env=self.env,cwd=self.repo,
                              text=True,capture_output=True,timeout=20)

    def test_install_modes_ignore_external_override(self):
        # Separate HOME for each full script run, avoiding reuse/backup collisions.
        for args, expected in [((), 'tools_stable.yml'),(('--sg',),'tools_stable_sg.yml'),(('--slim',),'tools_slim_stable.yml'),(('',),'tools_stable.yml')]:
            with self.subTest(args=args):
                if self.calls.exists(): self.calls.unlink()
                self.env['TOOLS_STABLE']='custom.yml'
                r=self.install(args=args)
                self.assertEqual(r.returncode,0,r.stderr)
                self.assertEqual(self.profile.read_text(),expected+'\n')
                mamba=[a for n,a in self.log() if n=='mamba']
                self.assertEqual(mamba,[['env','create','-f',expected]])
                self.assertIn('Installing workspace with '+expected,r.stdout)
                # Remove isolated HOME artifacts before next case.
                shutil.rmtree(self.home); self.home.mkdir(); self.ws.mkdir()

    def test_invalid_and_help_have_no_side_effects(self):
        for args,code in [(('--help',),0),(('--bad',),2),(('--sg','--slim'),2),(('--slim',''),2),(('sg',),2),(('--sg','--sg'),2)]:
            with self.subTest(args=args):
                r=self.install(args=args)
                self.assertEqual(r.returncode,code,r.stderr)
                self.assertFalse(self.calls.exists())
                self.assertFalse(self.profile.exists())
                self.assertIn('Usage:', r.stdout+r.stderr)

    def test_install_latest_and_failure(self):
        r=self.install(script='make_workspace_latest.sh')
        self.assertEqual(r.returncode,0,r.stderr)
        self.assertEqual(self.profile.read_text(),'tools.yml\n')

    def test_install_env_failure_preserves_old_record(self):
        for script in ['make_workspace_stable.sh','make_workspace_latest.sh']:
            with self.subTest(script=script):
                self.profile.write_text('old.yml\n'); self.env['FAIL']='env'
                r=self.install(script)
                self.assertNotEqual(r.returncode,0)
                self.assertEqual(self.profile.read_text(),'old.yml\n')

    def test_latest_fzf_pipeline_failure_and_fallback(self):
        self.profile.write_text('old.yml\n'); self.env['FAIL']='fzf'
        r=self.install('make_workspace_latest.sh')
        self.assertNotEqual(r.returncode,0,r.stderr)
        self.assertEqual(self.profile.read_text(),'old.yml\n')
        # tar mock succeeds even on wget failure; pipefail must still reject both sources.
        fzf=[a for n,a in self.log() if n=='wget' and 'fzf/releases' in a[-1]]
        self.assertEqual(len(fzf),2)
        shutil.rmtree(self.home); self.home.mkdir(); self.ws.mkdir()
        self.env['FAIL']='fzf-primary'; self.calls.unlink()
        r=self.install('make_workspace_latest.sh')
        self.assertEqual(r.returncode,0,r.stderr)
        self.assertEqual(self.profile.read_text(),'tools.yml\n')
        fzf=[a for n,a in self.log() if n=='wget' and 'fzf/releases' in a[-1]]
        self.assertEqual(len(fzf),2)

    def test_install_download_failure(self):
        for script in ['make_workspace_stable.sh','make_workspace_latest.sh']:
            with self.subTest(script=script):
                self.profile.write_text('old.yml\n'); self.env['FAIL']='download'
                r=self.install(script)
                self.assertNotEqual(r.returncode,0)
                self.assertEqual(self.profile.read_text(),'old.yml\n')

    def test_install_record_failure(self):
        self.env['FAIL']='record'
        r=self.install(args=('--slim',))
        self.assertNotEqual(r.returncode,0)
        self.assertIn('Cannot save',r.stderr)
        self.assertFalse(self.profile.exists())
        self.assertEqual(list(self.ws.glob('.tools_profile.*')),[])

    def test_profile_selection_and_nonexecution(self):
        for content,expected in [(None,'tools_stable.yml'),('', 'tools_stable.yml'),('tools.yml\n','tools.yml'),
             ('tools_stable_sg.yml\n','tools_stable_sg.yml'),('tools_slim_stable.yml','tools_slim_stable.yml'),
             ('custom.yml\n','custom.yml'),('one.yml\ntwo.yml\n','tools_stable.yml'),('one.yml\n\n','tools_stable.yml'),
             ('one.yml\r\n','tools_stable.yml'),('$(touch '+str(self.base/'EXECUTED')+')\n','$(touch '+str(self.base/'EXECUTED')+')')]:
            with self.subTest(content=content):
                if self.profile.exists(): self.profile.unlink()
                if content is not None: self.profile.write_text(content)
                r=self.update()
                self.assertEqual(r.returncode,0,r.stderr)
                self.assertEqual(self.profile.read_text(),expected+'\n')
                self.assertTrue(self.yaml_urls()[-1].endswith('/'+expected))
                self.assertFalse((self.base/'EXECUTED').exists())

    def test_external_and_user_override(self):
        self.profile.write_text('tools_slim_stable.yml\n')
        self.env['TOOLS_STABLE']='external.yml'
        r=self.update(); self.assertEqual(r.returncode,0,r.stderr)
        self.assertEqual(self.profile.read_text(),'external.yml\n')
        (self.home/'.userrc').write_text('export TOOLS_STABLE=user.yml\n')
        (self.ws/'.userrc').write_text('export TOOLS_STABLE=ws-user.yml\n')
        (self.ws/'.shell_common').write_text('export TOOLS_STABLE=common.yml\n')
        before=self.custom
        r=self.update(before=before); self.assertEqual(r.returncode,0,r.stderr)
        self.assertEqual(self.profile.read_text(),'common.yml\n')
        self.assertIn('ws-user.yml',(self.ws/'.userrc').read_text())

    def test_download_fallback(self):
        self.env['FAIL']='primary'
        r=self.update(); self.assertEqual(r.returncode,0,r.stderr)
        urls=self.yaml_urls(); self.assertEqual(len(urls),2)
        self.assertIn('gitee.com',urls[-1]); self.assertEqual(self.profile.read_text(),'tools_stable.yml\n')

    def test_update_failures_preserve_record(self):
        for fn in ['update_tools','update_tools_stable']:
            for fail in ['download','env','record','mktemp']:
                with self.subTest(fn=fn,fail=fail):
                    self.profile.write_text('old.yml\n'); self.env['FAIL']=fail
                    r=self.update(fn)
                    self.assertNotEqual(r.returncode,0,r.stderr)
                    self.assertEqual(self.profile.read_text(),'old.yml\n')
                    self.assertFalse((self.ws/'.tools_tmp.yml').exists())
                    self.assertEqual(list(self.ws.glob('.tools_profile.*')),[])

    def test_aux_failure_keeps_successful_env_record(self):
        for fn,expected in [('update_tools','tools.yml'),('update_tools_stable','tools_slim_stable.yml')]:
            with self.subTest(fn=fn):
                self.profile.write_text('tools_slim_stable.yml\n'); self.env['FAIL']='aux'
                r=self.update(fn); self.assertNotEqual(r.returncode,0)
                self.assertEqual(self.profile.read_text(),expected+'\n')

    def test_latest_then_stable_uses_new_record_in_same_shell(self):
        self.profile.write_text('tools_slim_stable.yml\n')
        r=self.run_shell(self.functions+'\nupdate_tools && update_tools_stable')
        self.assertEqual(r.returncode,0,r.stderr)
        self.assertTrue(all(u.endswith('/tools.yml') for u in self.yaml_urls()))
        self.assertEqual(self.profile.read_text(),'tools.yml\n')

    def test_workspace_update_preserves_record_and_user_files(self):
        (self.home/'.vim_runtime').mkdir()
        self.profile.write_text('tools_slim_stable.yml\n')
        for n in ['.userrc','.prerc','.shell_common','.mail']: (self.ws/n).write_text('user data\n')
        r=self.run_shell(self.functions+'\nupdate_workspace')
        self.assertEqual(r.returncode,0,r.stderr)
        self.assertEqual(self.profile.read_text(),'tools_slim_stable.yml\n')
        for n in ['.userrc','.prerc','.shell_common','.mail']: self.assertEqual((self.ws/n).read_text(),'user data\n')

    def test_atomic_record_write_and_directory_failures(self):
        helper=self.functions[:self.functions.index('update_tools()(\n')]
        self.profile.write_text('old.yml\n')
        # The injected printf writes a partial temporary file and then fails.
        r=self.run_shell(helper+'\nprintf() { builtin printf partial; return 5; }\nrecord_tools_profile new.yml')
        self.assertNotEqual(r.returncode,0)
        self.assertEqual(self.profile.read_text(),'old.yml\n')
        self.assertEqual(list(self.ws.glob('.tools_profile.*')),[])
        self.profile.unlink(); self.profile.mkdir()
        # Use the actual GNU mv, because this case tests its -T behavior.
        (self.bin/'mv').unlink()
        r=self.run_shell(helper+'\nrecord_tools_profile new.yml')
        self.assertNotEqual(r.returncode,0)
        self.assertEqual(list(self.profile.iterdir()),[])
        self.assertEqual(list(self.ws.glob('.tools_profile.*')),[])

    def test_record_helper_in_bash_and_zsh(self):
        helper=self.functions[:self.functions.index('update_tools()(\n')]
        for shell in [BASH,ZSH]:
            with self.subTest(shell=shell):
                r=self.run_shell(helper+'\nrecord_tools_profile custom.yml',shell)
                self.assertEqual(r.returncode,0,r.stderr)
                self.assertEqual(self.profile.read_text(),'custom.yml\n')

    def test_syntax_and_sg_removal(self):
        self.assertFalse((ROOT/'make_workspace_stable_sg.sh').exists())
        self.assertFalse((ROOT/'.ws/.tools_profile').exists())
        for shell,file in [(BASH,'make_workspace_stable.sh'),(BASH,'make_workspace_latest.sh'),(ZSH,'.zshrc')]:
            r=subprocess.run([shell,'-n',str(ROOT/file)],env=self.env,capture_output=True,text=True)
            self.assertEqual(r.returncode,0,r.stderr)


if __name__ == '__main__':
    if not ZSH: raise SystemExit('zsh is required; no real installer is ever run')
    unittest.main(verbosity=2)
