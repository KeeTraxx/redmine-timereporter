require 'net/http'
require 'json'

module TimeEntryPatch

  # Called when module is included
  # Allows methods to be executed in the context of the base module
  def self.included(base)
    # Extend base with additional class methods (aka static methods)
    base.extend(ClassMethods)

    # Extend instances of the base with instance methods
    base.include(InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development

      # Hook into Rails ActiveRecord lifecycle
      after_save :on_new_time_entry
    end

  end

  module ClassMethods
    # Post arbitrary data to the configured REST backend
    def post_to_server(data)
      # Get the callback url from the settings
      uri = URI(callback_url)
      req = Net::HTTP::Post.new(uri, initheader = {'Content-Type' => 'application/json'})
      # TODO: Basic auth support?
      #req.basic_auth @user, @pass
      req.body = data.to_json
      http = Net::HTTP.new(uri.host, uri.port)

      # Handle both http and https endpoints
      http.use_ssl = (uri.scheme == "https")

      # send the request (response is returned from this function)
      http.start { |http| http.request(req) }

    end

    # Get the callback url
    def callback_url
      Setting.plugin_reporter['callback_url']
    end

    # Select data form a object
    def pick(src, attrs)
      obj = {}

      attrs.each do |attr|
        obj[attr] = src[attr];
      end

      obj
    end
  end

  module InstanceMethods
    # Runs when a new TimeEntry model has been saved
    def on_new_time_entry
      project = Project.find(self[:project_id])
      issue = Issue.find(self[:issue_id])
      user = User.find(self[:user_id])

      # build project data
      p = self.class.pick(project, [
                                     :description,
                                     :homepage, :id,
                                     :identifier,
                                     :name,
                                     :parent_id,
                                     :status
                                 ])
      p[:custom_fields] = {}
      project.custom_field_values.each do |custom_field|
        p[:custom_fields][custom_field.custom_field[:name]] = custom_field.value
      end

      # build issue data
      i = self.class.pick(issue, [
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

      i[:custom_fields] = {}
      issue.custom_field_values.each do |custom_field|
        i[:custom_fields][custom_field.custom_field[:name]] = custom_field.value
      end

      # build user data
      u = self.class.pick(user, [:login, :mail, :firstname, :lastname, :id])
      u[:custom_fields] = {}
      user.custom_field_values.each do |custom_field|
        u[:custom_fields][custom_field.custom_field[:name]] = custom_field.value
      end

      # Combine everything
      data = {
          :user => u,
          :issue_id => issue[:id],
          :project_id => project[:id],
          :user_id => user[:id],
          :hours => self[:hours],
          :time_entry => self.class.pick(self, [:comments, :hours, :issue_id, :project_id, :spent_on, :tmonth, :tweek, :tyear]),
          :project => p,
          :issue => i
      }

      # Send everything to the server
      self.class.post_to_server(data)

    end


  end


end