module InteractiveSessionsHelper
  def display_status(session)
    if session.queued?
      "Queued"
    elsif session.held?
      "Held"
    elsif session.suspended?
      "Suspended"
    elsif session.starting?
      "Starting..."
    elsif session.running?
      "Running"
    else
      "Unknown"
    end
  end
end
