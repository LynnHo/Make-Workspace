import argparse
import json
import os
import smtplib
import socks
import subprocess
from urllib.parse import urlparse
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
from email.header import Header
from email.utils import parseaddr, formataddr

def send_email(
    smtp_server,
    port,
    sender_email,
    sender_password,
    receiver_email,
    subject,
    body,
    body_type='plain',
    sender_name=None,
    attachment_paths=None,
    get_socket_func=None
):
    """
    Function to send an email with or without attachments, with body content either in plain text or HTML.

    Parameters:
    - smtp_server: Address of the SMTP server.
    - port: Port number for the SMTP server.
    - sender_email: Email address of the sender.
    - sender_password: Password for the sender's email account.
    - receiver_email: Email address of the recipient.
    - subject: Subject of the email.
    - body: Body content of the email.
    - body_type: Type of the body content ('plain' or 'html', default is 'plain').
    - attachment_paths: List of file paths for the attachments (optional).
    """
    def _format_addr(s):
        name, addr = parseaddr(s)
        return formataddr((Header(name, 'utf-8').encode(), addr))

    if get_socket_func is not None:
        ori_get_socket_func = smtplib.SMTP._get_socket
        smtplib.SMTP._get_socket = get_socket_func

    try:
        try:
            server = smtplib.SMTP(smtp_server, port)
            server.ehlo()
            server.starttls()
            server.ehlo()
        except:
            if 'server' in locals():
                server.quit()
            server = smtplib.SMTP_SSL(smtp_server, port)

        message = MIMEMultipart()

        if sender_name is None:
            sender_name = sender_email.split('@')[0]
        message['From'] = _format_addr(f'{sender_name} <{sender_email}>')
        message['To'] = _format_addr(f'{receiver_email.split("@")[0]} <{receiver_email}>')
        message['Subject'] = Header(subject, 'utf-8').encode()
        message.attach(MIMEText(body, body_type, 'utf-8'))
        if attachment_paths is None:
            attachment_paths = []
        for attachment_path in attachment_paths:
            with open(attachment_path, 'rb') as attachment:
                part = MIMEBase('application', 'octet-stream')
                part.set_payload(attachment.read())
            encoders.encode_base64(part)
            filename = os.path.basename(attachment_path)
            part.add_header('Content-Disposition', f'attachment; filename={filename}')
            message.attach(part)

        server.login(sender_email, sender_password)
        server.sendmail(sender_email, receiver_email, message.as_string())
    except:
        raise
    finally:
        if get_socket_func is not None:
            smtplib.SMTP._get_socket = ori_get_socket_func
        if 'server' in locals():
            server.quit()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--mail_config', default='~/.ws/.mail')
    parser.add_argument('--receiver_email', default=None)
    parser.add_argument('--subject', required=True)
    parser.add_argument('--body', required=True)
    parser.add_argument('--body_type', choices=['plain', 'html'], default='plain')
    parser.add_argument('--attachment_paths', nargs='+', default=None)
    parser.add_argument('--proxy', default=None)
    parser.add_argument('--proxy_port', type=int, default=None)
    args = parser.parse_args()

    with open(os.path.expanduser(args.mail_config), 'r') as f:
        mail_config = json.load(f)

    if (args.proxy is None or args.proxy_port is None) and os.environ.get('http_proxy'):
        urlparsed = urlparse(os.environ.get('http_proxy'))
        args.proxy = urlparsed.hostname
        args.proxy_port = urlparsed.port

    if args.proxy is not None and args.proxy_port is not None:
        socks.set_default_proxy(socks.SOCKS5, args.proxy, args.proxy_port)
        socks.wrapmodule(smtplib)
        mail_config['smtp_server'] = subprocess.run(f"dig @223.5.5.5 {mail_config['smtp_server']} A +short | tail -1", shell=True, capture_output=True, text=True).stdout.strip()

    send_email(
        smtp_server=mail_config['smtp_server'],
        port=mail_config['port'],
        sender_email=mail_config['sender_email'],
        sender_password=mail_config['sender_password'],
        receiver_email=mail_config['default_receiver_email'] if args.receiver_email is None else args.receiver_email,
        subject=args.subject,
        body=args.body,
        body_type=args.body_type,
        attachment_paths=args.attachment_paths
    )
