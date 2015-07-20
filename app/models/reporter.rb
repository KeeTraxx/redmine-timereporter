require 'rubygems'
require 'net/http'
require 'json'

class Reporter < ActiveRecord::Base

  # Should be called by the Redmine Hook "controller_timelog_edit_before_save"
  def self.send_time_log(user, params, time_entry)

    # Basic validation, because there is no Hook named "controller_timelog_edit_after_save"
    if params["time_entry"]["spent_on"].blank? || params["time_entry"]["hours"].blank? || params["time_entry"]["activity_id"].blank?
      return
    end

    project = Project.find(time_entry[:project_id])
    issue = Issue.find(params[:issue_id])

    #Rails.logger.warn(issue.inspect)

    p = pick(project, [:description, :homepage, :id, :identifier, :name, :parent_id, :status])
    p[:custom_fields] = {}
    project.custom_field_values.each do |custom_field|
      p[:custom_fields][custom_field.custom_field[:name]] = custom_field.value
    end

    #Rails.logger.warn(project.custom_field_values)

    data = {
        :user => pick(user, [:login, :mail, :firstname, :lastname, :id]),
        :issue_id => params[:issue_id],
        :project_id => time_entry[:project_id],
        :user_id => user[:id],
        :hours => time_entry[:hours],
        :time_entry => pick(time_entry, [:comments, :hours, :issue_id, :project_id, :tmonth, :tweek, :tyear]),
        :project => p,
        :issue => pick(issue, [
                                :tracker_id,
                                :project_id,
                                :subject,
                                :description,
                                :due_date,
                                :category_id,
                                :status_id,
                                :assigned_to_id,
                                :priority_id,
                                :fixed_version_id,
                                :author_id,
                                :created_on,
                                :updated_on,
                                :start_date,
                                :done_ratio,
                                :estimated_hours,
                                :parent_id,
                                :root_id,
                                :closed_on
                            ])
    }

    #Rails.logger.warn(data)

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
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")

    response = http.start { |http| http.request(req) }

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