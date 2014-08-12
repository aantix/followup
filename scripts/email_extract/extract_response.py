import talon, sys, json
from talon import quotations
from talon.signature.bruteforce import extract_signature

talon.init()

html  = sys.argv[1]
reply = quotations.extract_from_html(html)

print json.dumps({'reply':reply})