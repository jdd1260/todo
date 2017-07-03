class ItemsController < ApplicationController
    before_action :get_list

    before_action :get_item, only: [:show, :update, :destroy]
    
    def index
        json_response(@list.items)
    end
    
    def create
        @item = @list.items.create!(item_params)
        json_response(@item, :created)
    end
    
    def show
        json_response(@item)
    end
    
    def update
        @item.update(item_params)
        head :no_content
    end
    
    def destroy
        @item.destroy
        head :no_content
    end
    
    private
        def item_params
            params.require(:item).permit(:text, :status)
        end
        
        def get_list
            @list = List.find(params[:list_id])
        end
        
        def get_item 
            @item = @list.items.find_by!(id: params[:id]) if @list
        end
end
