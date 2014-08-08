class RedmineReminder::Collector

	

  def collect_reminders(days)
    reminders = {}
	project_id = 0 # 0 to look in all projects
	
	unless days == "inactive"
		issues = issues_resolved_days_ago(days,project_id)
	else
		issues = issues_inactive(project_id)
	end
    
    issues.each do |issue|

      if issue.assigned_to
        reminders[issue.assigned_to] ||=
            RedmineReminder::Reminder.new(issue.assigned_to)
        reminders[issue.assigned_to][:assigned_to] << issue
      end

    end
 
    reminders.values.map &:uniq!
    reminders.values || []
  end

  private

  # Get issues that where resolved X days ago (exact)
  def issues_resolved_days_ago(days,project_id)
	if project_id == 0
		Issue.includes(:status, :assigned_to, :author, :project,:tracker)
					.where("status_id = 3 AND DATE(updated_on) = DATE_SUB(CURDATE(),INTERVAL ? DAY)",days)
					.all
	else
		Issue.includes(:status, :assigned_to, :author, :project,:tracker)
					.where("project_id = ? AND status_id = 3 AND DATE(updated_on) = DATE_SUB(CURDATE(),INTERVAL ? DAY)",project_id,days)
					.all
	end
  end
  
  def issues_inactive(project_id)
	if project_id == 0
		Issue.includes(:assigned_to, :author, :project, :tracker)
					.where("DATE(updated_on) < DATE_SUB(CURDATE(),INTERVAL 10 DAY) AND status_id <> 3 AND status_id <> 5")
					.all
	else
		Issue.includes(:assigned_to, :author, :project, :tracker)
					.where("project_id = ? AND DATE(updated_on) < DATE_SUB(CURDATE(),INTERVAL 10 DAY) AND status_id <> 3 AND status_id <> 5",project_id)
					.all
	end
  end
end
