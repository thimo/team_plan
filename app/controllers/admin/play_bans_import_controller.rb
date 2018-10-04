# frozen_string_literal: true

module Admin
  class PlayBansImportController < Admin::BaseController
    before_action :add_breadcrumbs

    def new
      authorize(PlayBan)
    end

    def create
      authorize(PlayBan)

      if (message = validate_params).present?
        flash.now[:danger] = message
        render :new

      else
        members = Member.where(association_number: params[:association_numbers].split).asc

        @action = params[:play_ban_action] # create / finish
        @date = params[:date].to_date
        @confirmed = params[:confirmed] == "true"
        @body = params[:body] == "true"

        @confirm_messages = members.map do |member|
          [member, process_play_ban(member)]
        end

        if @confirmed
          redirect_to [:admin, :play_bans]
        else
          render :confirm
        end
      end
    end

    private

      def add_breadcrumbs
        add_breadcrumb "Speelverboden", admin_play_bans_path
        add_breadcrumb "Import"
      end

      def validate_params
        return "Voer de KNVB nummers in" if params[:association_numbers].blank?
        return "Voer een datum in" if params[:date].blank?
        return "Selecteer aanmaken of afronden" if ["create", "finish"].exclude?(params[:play_ban_action])
        return "Voer een correcte datum in" unless params[:date].to_date rescue false
      end

      def process_play_ban(member)
        # Find active of future play ban
        play_bans = policy_scope(PlayBan).by_member(member).end_in_future

        if play_bans.size > 1
          "Meerdere actieve speelverboden gevonden, graag handmatig aanpassen"
        elsif play_bans.size == 1
          play_ban = play_bans.first
          process_existing_play_ban(play_ban)
        else
          create_play_ban(member)
        end
      end

      def process_existing_play_ban(play_ban)
        if create?
          current_date = play_ban.started_on
          play_ban.update(started_on: @date) if @confirmed
          "Speelverbod gevonden, de startdatum wordt aangepast van <b>#{l(current_date, format: :date_long)}</b> naar <b>#{l(@date, format: :date_long)}</b>"
        elsif finish?
          current_date = play_ban.ended_on
          play_ban.update(ended_on: @date) if @confirmed

          if play_ban.ended_on.blank?
            "Speelverbod gevonden, de einddatum wordt ingesteld op <b>#{l(@date, format: :date_long)}</b>"
          else
            "Speelverbod gevonden, de einddatum wordt aangepast van <b>#{l(current_date, format: :date_long)}</b> naar <b>#{l(@date, format: :date_long)}</b>"
          end
        end
      end

      def create_play_ban(member)
        if create?
          if @confirmed
            play_ban_type = if current_user.role?(Role::BEHEER_CONTRIBUTIE_SPEELVERBODEN)
                              PlayBan.play_ban_types[:contribution]
                            else
                              raise "Could not determine play_ban_type"
                            end
            PlayBan.create(member: member,
                           started_on: @date,
                           body: @body,
                           play_ban_type: play_ban_type)
          end

          "Speelverbod wordt aangemaakt met ingang van <b>#{l(@date, format: :date_long)}</b>"
        elsif finish?
          "Geen actief of aanstaand speelverbod gevonden"
        end
      end

      def create?
        @action == "create"
      end

      def finish?
        @action == "finish"
      end
  end
end
