import claw, sys, json
import HTMLParser

from claw import quotations

claw.init()

content_type = sys.argv[1]
message_body = HTMLParser.HTMLParser().unescape(unicode(sys.argv[2], 'utf-8'))

reply = quotations.extract_from(message_body, content_type)

print json.dumps({'reply':reply})

# sudo curl https://bootstrap.pypa.io/get-pip.py -o - | sudo python
# pip install claw