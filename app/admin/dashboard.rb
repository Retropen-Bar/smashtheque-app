ActiveAdmin.register_page "Dashboard" do

  menu priority: 1,
       label: proc {
          ('<i class="fas fa-fw fa-tachometer-alt"></i>'+I18n.t("active_admin.dashboard")).html_safe
        }

  content title: proc { I18n.t("active_admin.dashboard") } do
    render 'numbers'
    render 'paper_trail'
  end

end
