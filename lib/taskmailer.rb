require 'pony'
require 'psych'

class TaskMailer

  Basedir = File.expand_path("#{File.dirname(__FILE__)}/..")
  JOBS    = Psych.load_file("#{Basedir}/config/jobs.yaml") unless defined? JOBS
  SMTP    = Psych.load_file("#{Basedir}/config/smtp.yaml") unless defined? SMTP

  ##
  # main
  #
  def initialize
  end

  def email 
    JOBS.each do |title, job|
      body = get_email_contents(job)
      send_email(job, body)
    end
  end

  private

  def get_email_contents(job)
      output = Array.new

      # Get projects      
      job[:projects].each do |project|
        cmd = "project:#{project}"
        output.push( invoke_tw(cmd) )
      end
      
      # Get tasks due today and tomorrow
      job[:due].each do |due|
        cmd = "due:#{due}" 
        output.push( invoke_tw(cmd))
      end
      
      return output
  end

  def send_email(job, body)
    Pony.mail(
      :to => job[:email],
      :from => job[:from],
      :subject => job[:subject], 
      :body => body,
      :via => :smtp,
      :via_options => {
        :address              => SMTP[:address],
        :port                 => SMTP[:port],
        :enable_starttls_auto => SMTP[:enable_starttls_auto],
        :user_name            => SMTP[:user_name],
        :password             => SMTP[:password],
        :authentication       => SMTP[:authentication],
        :domain               => SMTP[:domain]
      }
    )
  end

  def invoke_tw(filter)
    cmd = "task minimal #{filter}"
    return %x(#{cmd})
  end
end
