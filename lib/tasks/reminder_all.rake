# redMine - project management software
# Copyright (C) 2008  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

desc <<-END_DESC
Send reminders about issues due in the next days.

See 'Reminder options' in administration menu for available options.

Example:
  rake redmine:send_reminders_all RAILS_ENV="production"
END_DESC

namespace :redmine do
  task :send_reminders_all => :environment do
    collector = RedmineReminder::Collector.new()
	i = [5,10,15]
	i.each do |d|
		collector.collect_reminders(d).each do |r|
		  next unless r.user.active?
		  ReminderAllMailer.with_synched_deliveries do
			ReminderAllMailer.deliver_reminder_all_if_any(
				r.user,
				r[:assigned_to],
				d
			)
		  end
		end
	end
	collector.collect_reminders(30).each do |r|
		  next unless r.user.active?
			ReminderAllMailer.deliver_reminder_closed(
				r.user,
				r[:assigned_to]
			)
			r[:assigned_to].each do |issue|
				#issue.status = IssueStatus.find_by_name("Closed")
				#issue.save
			end
	end
	collector.collect_reminders("inactive").each do |r|
		next unless r.user.active?
		ReminderAllMailer.deliver_reminder_inactive(
			r.user,
			r[:assigned_to]
		)
	end
  end
end

