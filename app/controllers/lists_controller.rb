class ListsController < ApplicationController
    before_action :get_list, only: [:show, :update, :destroy]
    
    def index
        @lists = List.all
        json_response(@lists)
    end
    
    def create
        @list = List.create!(list_params)
        json_response(@list, :created)
    end
    
    def show
        json_response(@list)
    end
    
    def update
        @list.update(list_params)
        head :no_content
    end
    
    def destroy
        @list.destroy
        head :no_content
    end
    
    private
        def list_params
            params.require(:list).permit(:title, :status)
        end
        
        def get_list
            @list = List.find(params[:id])
        end
        
end
