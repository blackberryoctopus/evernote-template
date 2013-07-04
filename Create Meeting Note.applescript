on date_format(old_date) -- Old_date is text, not a date.
	set {year:y, month:m, day:d} to old_date
	tell (y * 10000 + m * 100 + d) as string to text 1 thru 4 & "." & text 5 thru 6 & "." & text 7 thru 8
end date_format




set noteDate to date_format(current date)



tell application "Evernote"
	set importedNotes to import "/Users/gsogorka/ENMeetingTemplate.enex" to "FreeWheel"
	set newNote to item 1 of importedNotes
	
	tell application "Microsoft Outlook"
		set currentTime to time string of (current date)
		set currentSeconds to time of (current date)
		set currentHour to round (currentSeconds / 60 / 60) rounding down
		set currentHalfHour to currentHour * 60 * 60 + 30 * 60
		
		
		--round down to nearest hour; most likely start time for mtg
		set roundedHourDate to current date
		set time of roundedHourDate to currentHour * 60 * 60
		
		--round down to nearest half hour; 2nd most likely start time for mtg
		set roundedHalfHourDate to roundedHourDate
		set time of roundedHalfHourDate to currentHalfHour
		
		
		--reverse the list so the dates descend; this makes finding the current date and current meeting much much faster in the loop
		set calendarEvents to calendar events
		set reverseEvents to reverse of calendarEvents
		set found to false
		repeat with anEvent in reverseEvents
			
			set eventStartTime to start time of anEvent
			if (eventStartTime = roundedHourDate or eventStartTime = roundedHalfHourDate) then
				set theCurrentEvent to anEvent
				set eventSubject to (subject of theCurrentEvent)
				set attendeeList to attendees of theCurrentEvent
				set attendeeEmails to {}
				repeat with anAttendee in attendeeList
					set attendeeEmailObj to email address of anAttendee
					set attendeeEmail to address of attendeeEmailObj
					set attendeeName to name of attendeeEmailObj
					set end of attendeeEmails to (attendeeName & " - " & attendeeEmail)
				end repeat
				
				set found to true
			end if
			
			if found then exit repeat
		end repeat
	end tell
	
	
	
	-- Some date gymnastics
	set title of newNote to noteDate & " - " & eventSubject
	
	
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
	
end tell
