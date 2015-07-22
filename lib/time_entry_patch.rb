require 'net/http'
require 'json'

module TimeEntryPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development

      after_save :on_new_time_entry

    end

  end

  module ClassMethods
  end

  module InstanceMethods
    def on_new_time_entry
      Rails.logger.warn('on_new_time_entry')
      Rails.logger.warn(self.inspect)

      project = Project.find(self[:project_id])
      issue = Issue.find(self[:issue_id])
      user = User.find(self[:user_id])

      Rails.logger.warn(project)
      Rails.logger.warn(issue)
      Rails.logger.warn(user)

      p = pick(project, [:description, :homepage, :id, :identifier, :name, :parent_id, :status])
      p[:custom_fields] = {}
      project.custom_field_values.each do |custom_field|
        p[:custom_fields][custom_field.custom_field[:name]] = custom_field.value
      end

      #Rails.logger.warn(project.custom_field_values)

      i = pick(issue, [
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

      u = pick(user, [:login, :mail, :firstname, :lastname, :id])

      u[:custom_fields] = {}

      user.custom_field_values.each do |custom_field|
        u[:custom_fields][custom_field.custom_field[:name]] = custom_field.value
      end

      data = {
          :user => u,
          :issue_id => issue[:id],
          :project_id => project[:id],
          :user_id => user[:id],
          :hours => self[:hours],
          :time_entry => pick(self, [:comments, :hours, :issue_id, :project_id, :spent_on, :tmonth, :tweek, :tyear]),
          :project => p,
          :issue => i
      }

      #Rails.logger.warn(data)

      post_to_server(data)

      return true
    end


    def post_to_server(data)
      uri = URI(callback_url)
      req = Net::HTTP::Post.new(uri, initheader = {'Content-Type' => 'application/json'})
      #req.basic_auth @user, @pass
      req.body = data.to_json
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")

      response = http.start { |http| http.request(req) }

      return response
    end

    def callback_url
      return Setting.plugin_reporter['callback_url']
    end

    def pick(src, attrs)
      obj = {}

      attrs.each do |attr|
        obj[attr] = src[attr];
      end

      return obj
    end

  end



end