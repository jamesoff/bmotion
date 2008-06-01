import sys

try:
	import sqlite3
except:
	print "Unable to load sqlite3 library."
	print
	print "The dungeon collapses on your dreams. Your bot remains dumb\nand predictable."
	sys.exit(1)

def main():
	print "Opening database...",
	try:
		conn = sqlite3.connect('bmotion_thes.db');
		conn.isolation_level = "IMMEDIATE"
	except:
		print "failed."
		sys.exit(1)

	print "done."

	print "Preparing table...",

	try:
		conn.execute("""CREATE TABLE IF NOT EXISTS thes (
			word varchar(30) unique,
			syn text);""")
	except Exception, e:
		print "Unable to create table."
		print e
		sys.exit(1)

	try:
		conn.execute("""DROP INDEX IF EXISTS word_idx;""")
	except:
		print "Unable to drop index."
		sys.exit(1)

	print "OK"

	print "Opening thesaurus source file...",

	try:
		fh = open("mthesaur.txt", "r")
	except:
		print "failed."
		sys.exit(2)

	print "OK"

	print "Importing",

	count = 0
	errors = 0
	lines = 0

	for line in fh:
		line = line.strip()
		if line == "":
			continue
		lines += 1
		try:
			key = line.split(",")[0]
			syns = line[line.find(",")+1:]

			# rebuild syns list to make sure it's OK
			syn_list = syns.split(",")
			syns = ",".join([x.strip() for x in syn_list])
			conn.execute("INSERT INTO thes values (?, ?);", (key, syns))
			count += 1
		except Exception, e:
			errors += 1
		if lines % 10 == 0:
			if lines % 100 == 0:
				sys.stdout.write(str(lines))
			else:
				sys.stdout.write(".")
		
	print "\n%d entries imported, %d entries skipped." % (count, errors)
	if errors > 0:
		print "(Skipped entries are duplicates or are badly formatted.)"

	print "Preparing index...",

	try:
		conn.execute("CREATE INDEX word_idx ON thes (word);")
	except:
		print "failed."
		sys.exit(1)

	print "OK"
	print

	print "Finished."

if __name__ == "__main__":
	print "bMotion Thesaurus Import Tool"
	print
	main()

