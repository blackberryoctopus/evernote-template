on date_format(old_date)
	set {year:y, month:m, day:d} to old_date
	tell (y * 10000 + m * 100 + d) as string to text 1 thru 4 & "." & text 5 thru 6 & "." & text 7 thru 8
end date_format

-- Format current date into "yyyy.mm.dd" for note title
set noteDate to date_format(current date)

set foundOutlookEvent to false

tell application "Microsoft Outlook"
	-- Figure out the nearest half hour
	set nearestHalfHour to round ((time of (current date)) / 1800)
	set targetDate to current date
	set time of targetDate to (nearestHalfHour * 1800)
	
	set calendarEvents to calendar events whose start time � targetDate
	repeat with anEvent in calendarEvents
		-- log "Checking event with subj=" & (subject of anEvent) & " / start=" & (start time of anEvent)
		
		if (start time of anEvent = targetDate) then
			set eventSubject to (subject of anEvent)
			set attendeeList to attendees of anEvent
			set attendeeEmails to {}
			repeat with anAttendee in attendeeList
				set attendeeEmailObj to email address of anAttendee
				set attendeeEmail to address of attendeeEmailObj
				set attendeeName to name of attendeeEmailObj
				set end of attendeeEmails to (attendeeName & " - " & attendeeEmail)
			end repeat
			
			set foundOutlookEvent to true
		end if
		
		if foundOutlookEvent then exit repeat
	end repeat
end tell

tell application "Evernote"
	set importedNotes to import POSIX file "/Users/jlee/src/evernote-template/ENMeetingTemplate.enex" to "FreeWheel (JBL)"
	set newNote to item 1 of importedNotes
	
	-- Some date gymnastics
	set titleText to noteDate
	if (foundOutlookEvent) then
		set titleText to titleText & " - " & eventSubject
	end if
	
	set title of newNote to titleText
	
	if (foundOutlookEvent) then
		set noteContent to HTML content of (newNote)
		set attendeeHTML to ""
		repeat with person in attendeeEmails
			set attendeeHTML to attendeeHTML & person & "<br/>"
		end repeat
		
		-- parse the html string of note and regexp with sed to find 'attendees'
		--http://stackoverflow.com/questions/10129285/sed-command-insert-i-from-applescript
		set sedCommandResults to do shell script "echo " & quoted form of noteContent & " | sed '
	/Attendees/ a\\
	<div>" & (attendeeHTML as string) & "</div>
	'"
		
		-- http://veritrope.com/code/evernote-add-text-to-beginning-of-notes/ 
		-- please see disclaimer; according to blog the script actions have potential to trigger bug in evernote that blows away images/audio attachments from a note
		set (HTML content of item 1 of newNote) to sedCommandResults
	end if
	
end tell
