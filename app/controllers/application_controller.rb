#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ApplicationController < ActionController::Base
  has_mobile_fu
  protect_from_forgery :except => :receive

  before_filter :set_contacts_notifications_and_status, :except => [:create, :update]
  before_filter :count_requests
  before_filter :set_invites
  before_filter :set_locale
  before_filter :which_action_and_user

  def set_contacts_notifications_and_status
    if user_signed_in?
      @aspect = nil
      @object_aspect_ids = []
      @all_aspects = current_user.aspects.includes(:aspect_memberships)
      @notification_count = Notification.for(current_user, :unread =>true).count
    end
  end

  def count_requests
    @request_count = Request.where(:recipient_id => current_user.person.id).count if current_user
  end

  def set_invites
    if user_signed_in?
      @invites = current_user.invites
    end
  end

  def which_action_and_user
    str = "controller=#{self.class} action=#{self.action_name} "
    if current_user
      str << "uid=#{current_user.id}"
    else
      str << 'uid=nil'
    end
    Rails.logger.info str
  end

  def set_locale
    if user_signed_in?
      I18n.locale = current_user.language
    else
      I18n.locale = request.compatible_language_from AVAILABLE_LANGUAGE_CODES
    end
  end

  def get_javascript_strings_for(language)
    Il8n.t('javascripts').to_json
  end
end
