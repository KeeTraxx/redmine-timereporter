require 'rubygems'
require 'net/http'
require 'json'

class Reporter < ActiveRecord::Base

  # Should be called by the Redmine Hook "controller_timelog_edit_before_save"
  def self.send_time_log(user, params, time_entry)


    #Rails.logger.warn( CustomField.find(:all) )

    project = Project.find(time_entry[:project_id])
    p = pick(project, [:description, :homepage, :id, :identifier, :name, :parent_id, :status])
    p[:custom_fields] = {}
    project.custom_field_values.each do |custom_field|
      #Rails.logger.warn("blka")
      #Rails.logger.warn(custom_field)
      #Rails.logger.warn(custom_field.inspect)
      #Rails.logger.warn(custom_field.methods(true))
      #Rails.logger.warn(custom_field.custom_field)
      p[:custom_fields][custom_field.custom_field[:name]] = custom_field.value
      #name = custom_field[:custom_field][:name]
      #p[:custom_fields][name] = custom_field[:value]
    end

    #Rails.logger.warn(project.custom_field_values)

    data = {
        :user => pick(user, [:login, :email, :firstname, :lastname, :id]),
        :issue_id => params[:issue_id],
        :project_id => time_entry[:project_id],
        :user_id => user[:id],
        :hours => time_entry[:hours],
        :time_entry => pick(time_entry, [:comments, :hours, :issue_id, :project_id, :tmonth, :tweek, :tyear]),
        :project => p
    }

    post_to_server(data)
  end

  # Should be called by the Redmine Hook "controller_issues_edit_after_save"
  def self.send_issue_update(user, issueId, journal)
    changes = []
    journal.details.each do |j|
      changes.push({
                       "property" => j.prop_key,
                       "value" => j.value
                   })
    end
    u = flatten_user(user)
    post_to_server({
                       "type" => "issue",
                       "user" => u.to_json,
                       "issue" => issueId,
                       "comment" => journal.notes,
                       "changes" => changes.to_json,
                   })
  end

  # HTTP POST any kind of data to server (preferably JSON)
  def self.post_to_server(data)
    uri = URI(self.callback_url)
    req = Net::HTTP::Post.new(uri, initheader = {'Content-Type' => 'application/json'})
    #req.basic_auth @user, @pass
    req.body = data.to_json
    response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request(req) }

    return response
  end

  private
  def self.callback_url()
    return Setting.plugin_reporter['callback_url']
  end

  private
  def self.pick(src, attrs)
    obj = {}

    attrs.each do |attr|
      obj[attr] = src[attr];
    end

    return obj
  end


end