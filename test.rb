require 'net/http'
require 'json'
obj = {
    :login => "admin",
    :email => nil,
    :firstname => "Redmine",
    :lastname => "Admin",
    :id => 1
}

a = {
    :user => obj,
    :issue_id => "1",
    :project_id => 1,
    :user_id => 1,
    :hours => 2.0,
    :time_entry => {
        :comments => "Test3",
        :hours => 2.0,
        :issue_id => 1,
        :project_id => 1,
        :tmonth => 7,
        :tweek => 29,
        :tyear => 2015
    }
}

#a = ActiveSupport::JSON.encode(a)
puts a
puts a.to_json

#client = HTTPClient.new
#client.debug_dev = STDOUT if $DEBUG

#resp = client.post("http://130.92.94.58:3000", a)

uri = URI("http://130.92.94.58:3000")

req = Net::HTTP::Post.new(uri, initheader = {'Content-Type' =>'application/json'})
#req.basic_auth @user, @pass
req.body = a.to_json
response = Net::HTTP.new(uri.host, uri.port).start {|http| http.request(req) }


puts response