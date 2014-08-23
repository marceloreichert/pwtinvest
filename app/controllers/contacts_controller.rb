class ContactsController < ApplicationController
  load_and_authorize_resource

  # GET /contacts/new
  # GET /contacts/new.xml
  def new
    @contacts = Contact.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @contacts }
    end
  end

  # POST /fale_conoscos
  # POST /fale_conoscos.xml
  def create
    @contacts = Contact.new(params[:contact])

    respond_to do |format|
      if @contacts.save
        flash[:notice] = 'Mensagem enviada com sucesso.'
        format.html { redirect_to(root_path) }
        format.xml  { render :xml => @contacts, :status => :created, :location => @contacts }
      else
        flash[:notice] = "Erro ao enviar mensagem"
        format.html { render :action => "new" }
        format.xml  { render :xml => @contacts.errors }
      end
    end
  end

end
