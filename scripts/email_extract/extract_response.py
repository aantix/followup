import talon, sys, json
import HTMLParser

from talon import quotations
from talon.signature.bruteforce import extract_signature

talon.init()

content_type = sys.argv[1]
message_body = HTMLParser.HTMLParser().unescape(sys.argv[2])

reply = quotations.extract_from(message_body, content_type)

print json.dumps({'reply':reply})