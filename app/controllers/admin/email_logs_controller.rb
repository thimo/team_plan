class Admin::EmailLogsController < AdminController
  add_breadcrumb "E-mail log", :admin_email_logs_path

  def index
    authorize EmailLog
    @email_logs = policy_scope(EmailLog).order(:created_at).reverse_order.page params[:page]
  end

  def show
    @email_log = EmailLog.find(params[:id])
    authorize @email_log
  end

end
