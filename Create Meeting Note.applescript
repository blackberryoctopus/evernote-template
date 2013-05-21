on date_format(old_date) -- Old_date is text, not a date.
	set {year:y, month:m, day:d} to old_date
	tell (y * 10000 + m * 100 + d) as string to text 1 thru 4 & "." & text 5 thru 6 & "." & text 7 thru 8
end date_format

set noteDate to date_format(current date)

tell application "Evernote"
	set importedNotes to import "ENMeetingTemplate.enex" to "FreeWheel"
	set newNote to item 1 of importedNotes
	
	-- Some date gymnastics
	set title of newNote to noteDate & " - "
end tell
