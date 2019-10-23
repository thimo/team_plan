# frozen_string_literal: true

module Admin
  class PlayBansController < Admin::BaseController
    before_action :create_resource, only: [:new, :create]
    before_action :set_resource, only: [:show, :edit, :update, :destroy]
    before_action :add_breadcrumbs

    def index
      @play_bans = policy_scope(PlayBan).active.order_started_on
      @play_bans_future = policy_scope(PlayBan).start_in_future.order_started_on
      @play_bans_past = policy_scope(PlayBan).end_in_past.order_ended_on
      authorize @play_bans
    end

    def show; end

    def new; end

    def create
      if @play_ban.save
        redirect_to admin_play_bans_path, notice: "Speelverbod is toegevoegd."
      else
        render :new
      end
    end

    def edit; end

    def update
      if @play_ban.update(permitted_attributes(@play_ban))
        redirect_to admin_play_bans_path, notice: "Speelverbod is aangepast."
      else
        render "edit"
      end
    end

    def destroy
      redirect_to admin_play_bans_path, notice: "Speelverbod is verwijderd."
      @play_ban.destroy
    end

    private

      def create_resource
        @play_ban = PlayBan.new(started_on: Time.zone.today)
        @play_ban.play_ban_type = PlayBan.play_ban_types[:contribution] if current_user.role?(Role::BEHEER_CONTRIBUTIE_SPEELVERBODEN)
        @play_ban.update(permitted_attributes(@play_ban)) if action_name == "create"
        authorize @play_ban
      end

      def set_resource
        @play_ban = PlayBan.find(params[:id])
        authorize @play_ban
      end

      def add_breadcrumbs
        add_breadcrumb "Speelverboden", admin_play_bans_path
        return if @play_ban.nil?

        if @play_ban.new_record?
          add_breadcrumb "Nieuw"
        else
          add_breadcrumb @play_ban.member.name, [:edit, :admin, @play_ban]
        end
      end
  end
end
