module Admin
  class EmailLogsController < Admin::BaseController
    add_breadcrumb "E-mail log", :admin_email_logs_path

    def index
      @email_logs = policy_scope(EmailLog).order(:created_at).reverse_order.page(params[:page]).per(50)
      authorize @email_logs
    end

    def show
      @email_log = EmailLog.find(params[:id])
      authorize @email_log
    end
  end
end
