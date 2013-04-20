require 'csv'
require 'sunlight'
require 'erb'

Sunlight::Base.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_homephone(homephone)
	homephone.gsub!(/[^0-9]/, '')
	if homephone.nil?
		"0000000000"
	elsif homephone.size == 10
		homephone
	elsif homephone[0] == "1" && homephone.length == 11
		homephone[1..10]
	elsif homephone[0] != "1" && homephone.length == 11
		"0000000000"
	elsif homephone.length > 11 || homephone.length < 10
		"0000000000"
	end				
end

def best_hours(hours)
	sorted_hours = hours.select{|item| hours.count(item) > 1}.sort_by{|item| hours.count(item)}.uniq
	first_place = sorted_hours.pop
	second_place = sorted_hours.pop
	"Best hours of the day: #{first_place} & #{second_place}"
end

def best_days(days)
	sorted_days = days.select{|item| days.count(item) > 1}.sort_by{|item| days.count(item)}.uniq
	first_place = sorted_days.pop
	second_place = sorted_days.pop
	"Best days of the week: #{first_place} & #{second_place}"
end

def legislators_for_zipcode(zipcode)
  Sunlight::Legislator.all_in_zipcode(zipcode)
end

def save_thank_you_letters(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end

puts "EventManager initialized."

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter
hours = []
days = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  homephone = clean_homephone(row[:homephone])
  regdate = DateTime.strptime(row[:regdate], '%m/%d/%y %k:%M')
  legislators = legislators_for_zipcode(zipcode)
  hours << regdate.strftime("%l%P")
  days << regdate.strftime("%A")

  # form_letter = erb_template.result(binding)

  # save_thank_you_letters(id,form_letter)
end
puts best_hours(hours)
puts best_days(days)