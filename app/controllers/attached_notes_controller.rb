class AttachedNotesController < ApplicationController
  
  before_filter :authenticate_user!
  
  def create
    @attached_note = AttachedNote.new(params[:attached_note])
    
    respond_to do |format|
      if @attached_note.save
          format.js { render 'attached_notes/create' }
      end
    
    end
  end
  
  def update
    @attached_note = AttachedNote.find_by_id(params[:id])
    
    respond_to do |format|
      if @attached_note.update_attributes(params[:attached_note])
        format.js { render 'attached_notes/show' }
      end
    end
    
  end
  
  def show
    @attached_note = AttachedNote.find_by_id(params[:id])
  end
  
  def index
    @customer = current_user.customers.find(params[:customer_id])
    @attached_notes = @customer.attached_notes.paginate(:per_page => 5, :page => params[:page])
  end
  
  def edit
    
    @attached_note = AttachedNote.find_by_id(params[:id])
    
    respond_to do |format|
      format.js { render 'attached_notes/edit' }
    end
  end
  
  def destroy
    @attached_note = AttachedNote.find(params[:id])
    
    @attached_note.destroy
    
    respond_to do |format|
      format.js { render 'attached_notes/delete'}
    end
  end
  
end
