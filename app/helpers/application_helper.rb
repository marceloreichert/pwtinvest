module ApplicationHelper
  include FusionChartsHelper

  #----------------------------------------------------------------------------
  def tabless_layout?
    %w(authentications passwords).include?(controller.controller_name) ||
    ((controller.controller_name == "users") && (%w(create new).include?(controller.action_name)))
  end

  # Show existing flash or embed hidden paragraph ready for flash[:notice]
  #----------------------------------------------------------------------------
  def show_flash(options = { :sticky => false })
    [:error, :warning, :info, :notice].each do |type|
      if flash[type]
        html = content_tag(:p, h(flash[type]), :id => "flash")
        return html << content_tag(:script, "crm.flash('#{type}', #{options[:sticky]})", :type => "text/javascript")
      end
    end
    content_tag(:p, nil, :id => "flash", :style => "display:none;")
  end

  #----------------------------------------------------------------------------
  def subtitle(id, hidden = true, text = id.to_s.split("_").last.capitalize)
    content_tag("div",
      link_to_remote("<small>#{ hidden ? "&#9658;" : "&#9660;" }</small> #{text}",
       :url => url_for(:controller => :home, :action => :toggle, :id => id),
        :before => "crm.flip_subtitle(this)"
      ), :class => "subtitle")
  end

  #----------------------------------------------------------------------------
  def load_select_popups_for(related, *assets)
    js = assets.inject("") do |str, asset|
      str << render(:partial => "common/select_popup", :locals => { :related => related, :popup => asset })
    end

    content_for(:javascript_epilogue) do
      "document.observe('dom:loaded', function() { #{js} });"
    end
  end

  #----------------------------------------------------------------------------
  def link_to_inline(id, url, options = {})
    text = options[:text] || id.to_s.titleize
    text = (arrow_for(id) + text) unless options[:plain]
    related = (options[:related] ? ", related: '#{options[:related]}'" : "")

    link_to_remote(text,
      :url    => url,
      :method => :get,
      :with   => "{ cancel: Element.visible('#{id}')#{related} }"
    )
  end

  #----------------------------------------------------------------------------
  def arrow_for(id)
    content_tag(:span, "&#9658;", :id => "#{id}_arrow", :class => :arrow)
  end

  #----------------------------------------------------------------------------
  def link_to_edit(model)
    name = model.class.name.underscore.downcase
    link_to_remote(t(:edit),
      :method => :get,
      :url    => send("edit_#{name}_path", model),
      :with   => "{ previous: crm.find_form('edit_#{name}') }"
    )
  end

  #----------------------------------------------------------------------------
  def link_to_delete(model)
    name = model.class.name.underscore.downcase
    link_to_remote(t(:delete) + "!",
      :method => :delete,
      :url    => send("#{name}_path", model),
      :before => visual_effect(:highlight, dom_id(model), :startcolor => "#ffe4e1")
    )
  end

  #----------------------------------------------------------------------------
  def link_to_discard(model)
    name = model.class.name.downcase
    current_url = (request.xhr? ? request.referer : request.request_uri)
    parent, parent_id = current_url.scan(%r|/(\w+)/(\d+)|).flatten

    link_to_remote(t(:discard),
      :method => :post,
      :url    => url_for(:controller => parent, :action => :discard, :id => parent_id),
      :with   => "{ attachment: '#{model.class.name}', attachment_id: #{model.id} }",
      :before => visual_effect(:highlight, dom_id(model), :startcolor => "#ffe4e1")
    )
  end

  #----------------------------------------------------------------------------
  def link_to_cancel(url)
    link_to_remote(t(:cancel), :url => url, :method => :get, :with => "{ cancel: true }")
  end

  #----------------------------------------------------------------------------
  def link_to_close(url)
    content_tag("div", "x",
      :class => "close", :title => t(:close_form),
      :onmouseover => "this.style.background='lightsalmon'",
      :onmouseout => "this.style.background='lightblue'",
      :onclick => remote_function(:url => url, :method => :get, :with => "{ cancel: true }")
    )
  end

  # Bcc: to dropbox address if the dropbox has been set up.
  #----------------------------------------------------------------------------
  def link_to_email(email, length = nil)
    name = (length ? truncate(email, :length => length) : email)
    if Setting.email_dropbox && Setting.email_dropbox[:address].present?
      mailto = "#{email}?bcc=#{Setting.email_dropbox[:address]}"
    else
      mailto = email
    end
    link_to(h(name), "mailto:#{mailto}", :title => email)
  end

  #----------------------------------------------------------------------------
  def jumpbox(current)
    tabs = [ :campaigns, :accounts, :leads, :contacts, :opportunities ]
    current = tabs.first unless tabs.include?(current)
    tabs.inject([]) do |html, tab|
      html << link_to_function(t("tab_#{tab}"), "crm.jumper('#{tab}')", :class => (tab == current ? 'selected' : ''))
    end.join(" | ")
  end

  #----------------------------------------------------------------------------
  def styles_for(*models)
    render :partial => "common/inline_styles", :locals => { :models => models }
  end

  #----------------------------------------------------------------------------
  def hidden;    { :style => "display:none;"       }; end
  def exposed;   { :style => "display:block;"      }; end
  def invisible; { :style => "visibility:hidden;"  }; end
  def visible;   { :style => "visibility:visible;" }; end

  #----------------------------------------------------------------------------
  def one_submit_only(form)
    { :onsubmit => "$('#{form}_submit').disabled = true" }
  end

  #----------------------------------------------------------------------------
  def hidden_if(you_ask)
    you_ask ? hidden : exposed
  end

  #----------------------------------------------------------------------------
  def invisible_if(you_ask)
    you_ask ? invisible : visible
  end

  #----------------------------------------------------------------------------
  def highlightable(id = nil, color = {})
    color = { :on => "seashell", :off => "white" }.merge(color)
    show = (id ? "$('#{id}').style.visibility='visible'" : "")
    hide = (id ? "$('#{id}').style.visibility='hidden'" : "")
    { :onmouseover => "this.style.background='#{color[:on]}'; #{show}",
      :onmouseout  => "this.style.background='#{color[:off]}'; #{hide}"
    }
  end

  #----------------------------------------------------------------------------
  def confirm_delete(model)
    question = %(<span class="warn">#{t(:confirm_delete, model.class.to_s.downcase)}</span>)
    yes = link_to(t(:yes_button), model, :method => :delete)
    no = link_to_function(t(:no_button), "$('menu').update($('confirm').innerHTML)")
    update_page do |page|
      page << "$('confirm').update($('menu').innerHTML)"
      page[:menu].replace_html "#{question} #{yes} : #{no}"
    end
  end

  #----------------------------------------------------------------------------
  def spacer(width = 10)
    image_tag "1x1.gif", :width => width, :height => 1, :alt => nil
  end

  # Reresh sidebar using the action view within the current controller.
  #----------------------------------------------------------------------------
  def refresh_sidebar(action = nil, shake = nil)
    refresh_sidebar_for(controller.controller_name, action, shake)
  end

  # Refresh sidebar using the action view within an arbitrary controller.
  #----------------------------------------------------------------------------
  def refresh_sidebar_for(view, action = nil, shake = nil)
    update_page do |page|
      page[:sidebar].replace_html :partial => "layouts/sidebar", :locals => { :view => view, :action => action }
      page[shake].visual_effect(:shake, :duration => 0.4, :distance => 3) if shake
    end
  end


  #----------------------------------------------------------------------------
  def options_menu_item(option, key, url = nil)
    name = t("option_#{key}")
    "{ name: \"#{name.titleize}\", on_select: function() {" +
    remote_function(
      :url       => url || send("redraw_#{controller.controller_name}_path"),
      :with      => "{ #{option}: '#{key}' }",
      :condition => "$('#{option}').innerHTML != '#{name}'",
      :loading   => "$('#{option}').update('#{name}'); $('loading').show()",
      :complete  => "$('loading').hide()"
    ) + "}}"
  end

  # Ajax helper to pass browser timezone offset to the server.
  #----------------------------------------------------------------------------
  def get_browser_timezone_offset
    unless session[:timezone_offset]
      remote_function(
        :url  => url_for(:controller => :home, :action => :timezone),
        :with => "{ offset: (new Date()).getTimezoneOffset() }"
      )
    end
  end

  #----------------------------------------------------------------------------
  def localize_calendar_date_select
    update_page_tag do |page|
      page.assign '_translations', { 'OK' => t('calendar_date_select.ok'), 'Now' => t('calendar_date_select.now'), 'Today' => t('calendar_date_select.today'), 'Clear' => t('calendar_date_select.clear') }
      page.assign 'Date.weekdays', t('date.abbr_day_names')
      page.assign 'Date.months', t('date.month_names')[1..-1]
    end
  end

  # Users can upload their avatar, and if it's missing we're going to use
  # gravatar. For leads and contacts we always use gravatars.
  #----------------------------------------------------------------------------
  def avatar_for(model, args = {})
    args[:size]  ||= "75x75"
    args[:class] ||= "gravatar"
    if model.avatar
      image_tag(model.avatar.image.url(Avatar.styles[args[:size]]), args)
    elsif model.email
      gravatar(model.email, { :default => default_avatar_url }.merge(args))
    else
      image_tag("avatar.jpg", args)
    end
  end

  # Add default avatar image and invoke original :gravatar_for defined by the
  # gravatar plugin (see vendor/plugins/gravatar/lib/gravatar.rb)
  #----------------------------------------------------------------------------
  def gravatar_for(model, args = {})
    super(model, { :default => default_avatar_url }.merge(args))
  end

  #----------------------------------------------------------------------------
  def default_avatar_url
    "#{request.protocol + request.host_with_port}" + Setting.base_url.to_s + "/images/avatar.jpg"
  end


  # Render a text field that is part of compound address.
  #----------------------------------------------------------------------------
  def address_field(form, object, attribute, extra_styles)
    hint = "#{t(attribute)}..."
    if object.send(attribute).blank?
      object.send("#{attribute}=", hint)
      form.text_field(attribute,
        :hint    => true,
        :style   => "margin-top: 6px; color:silver; #{extra_styles}",
        :onfocus => "crm.hide_hint(this)",
        :onblur  => "crm.show_hint(this, '#{hint}')"
      )
    else
      form.text_field(attribute,
        :hint    => false,
        :style   => "margin-top: 6px; #{extra_styles}",
        :onfocus => "crm.hide_hint(this, '#{escape_javascript(object.send(attribute))}')",
        :onblur  => "crm.show_hint(this, '#{hint}')"
      )
    end
  end

  # Return true if:
  #   - it's an Ajax request made from the asset landing page (i.e. create opportunity
  #     from a contact landing page) OR
  #   - we're actually showing asset landing page.
  #----------------------------------------------------------------------------
  def shown_on_landing_page?
    !!((request.xhr? && request.referer =~ %r|/\w+/\d+|) ||
       (!request.xhr? && request.request_uri =~ %r|/\w+/\d+|))
  end

end
