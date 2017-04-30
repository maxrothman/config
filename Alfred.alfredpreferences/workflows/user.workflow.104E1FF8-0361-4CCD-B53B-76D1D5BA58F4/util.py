"""Basic utility library"""

import urllib2

def convert_time(seconds):
    if seconds == '1':
        return '%s second' % seconds
    return '%s seconds' % seconds

def internet_on():
    try:
        response = urllib2.urlopen('http://google.com',timeout=1)
        return True
    except urllib2.URLError as err: pass
    return False

def find_icon(link):
    if link['mimeType'] == 'application/vnd.google-apps.document':
        icon = './icons/doc.png'
    elif link['mimeType'] == 'application/vnd.google-apps.spreadsheet':
        icon = './icons/sheet.png'
    elif link['mimeType'] == 'application/vnd.google-apps.presentation':
        icon = './icons/slide.png'
    elif link['mimeType'] == 'application/vnd.google-apps.form':
        icon = './icons/form.png'
    elif link['mimeType'] == 'application/pdf':
        icon = './icons/pdf.png'
    else:
        icon = './icons/pdf.png'
    return icon
