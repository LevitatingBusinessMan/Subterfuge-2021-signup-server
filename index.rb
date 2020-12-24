require "sinatra"
require "sqlite3"
require "sinatra/cookies"

set :port, 3000
set :public_folder, __dir__ + "/public"

$db = SQLite3::Database.new "data.db"

$db.execute <<-SQL
	CREATE TABLE IF NOT EXISTS attendees (
		name varchar(30),
		cookie varchar(20),
		ip varchar(15)
	);
SQL

def get_names
	rows = $db.execute "select * from attendees"
	names = rows.map { |row| row[0] }
	names
end

before do
	if !request.cookies["session"]
		cookies["session"] = (0...8).map { (65 + rand(26)).chr }.join
	end
end

get "/" do
	slim :index
end

post "/signup" do
	name = params["name"]

	rows = $db.execute "select * from attendees"

	if !rows.any? {
		|row| row[2] == request.ip or row[1] == request.cookies["session"]
	} && get_names.length < 10
		$db.execute "INSERT INTO attendees VALUES ('#{name}','#{request.cookies["session"]}','#{request.ip}');"
		puts "#{request.ip} Added #{name}"
	end


	slim :index
end
