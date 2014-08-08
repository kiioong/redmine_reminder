class ReminderAllMailer < Mailer
  helper :reminder_all

  def reminder_all(user, assigned_issues, days)
    recipients = user.mail
    issues_count = (assigned_issues).uniq.size
    plural_subject_term = case issues_count
      when 1 then
        :mail_subject_reminder_all1
      else
        :mail_subject_reminder_all2
    end
    subject = l(plural_subject_term, :count => issues_count, :days => days)
    @assigned_issues = assigned_issues
    @days = days
    @issues_url = url_for(:controller => 'issues', :action => 'index',
                          :set_filter => 1, :assigned_to_id => user.id,
                          :sort_key => 'due_date', :sort_order => 'asc')

    mail :to => recipients, :subject => subject
  end
  
  def reminder_closed(user, assigned_issues)
	recipients = user.mail
	issues_count = (assigned_issues).uniq.size
	if issues_count == 1
		subject = l(:mail_subject_reminder_closed1, :count => issues_count)
	else
		subject = l(:mail_subject_reminder_closed2, :count => issues_count)
	end
	@assigned_issues = assigned_issues
	@days = 30
	@issues_url = url_for(:controller => 'issues', :action => 'index',
						  :set_filter => 1, :assigned_to_id => user.id,
						  :sort_key => 'due_date', :sort_order => 'asc')
	mail :to => recipients, :subject => subject
  end
  
  def reminder_inactive(user,assigned_issues)
	recipients = user.mail
	issues_count = (assigned_issues).uniq.size
	if issues_count == 1
		subject = l(:mail_subject_reminder_inactive1, :count => issues_count)
	else
		subject = l(:mail_subject_reminder_inactive2, :count => issues_count)
	end
	@assigned_issues = assigned_issues
	@days = 30
	@issues_url = url_for(:controller => 'issues', :action => 'index',
						  :set_filter => 1, :assigned_to_id => user.id,
						  :sort_key => 'due_date', :sort_order => 'asc')
	mail :to => recipients, :subject => subject
  end

  def self.deliver_reminder_all_if_any(user, assigned_issues, days)
    issues_count = (assigned_issues).uniq.size
    reminder_all(user, assigned_issues, days).deliver if issues_count > 0
  end
  
  def self.deliver_reminder_closed(user, assigned_issues)
	issues_count = (assigned_issues).uniq.size
	reminder_closed(user, assigned_issues).deliver if issues_count > 0
  end
  
  def self.deliver_reminder_inactive(user,assigned_issues)
	issues_count = (assigned_issues).uniq.size
	reminder_inactive(user,assigned_issues).deliver if issues_count > 0
  end
end
