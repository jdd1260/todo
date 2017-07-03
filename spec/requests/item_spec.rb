require 'rails_helper'
require 'rspec/json_expectations'

describe "Items API" do
  describe "GET items" do
    context "when list does not exist" do
      before(:each) do
        get '/lists/abc/items'
      end
      it 'returns a 404 error' do
        expect(response.status).to eq(404)
      end
    end
    context "when list exists but no items" do
      let!(:list) { 
        List.create(title: 'First List', status: 'Unstarted') 
      }
      before(:each) do
        get "/lists/#{list.id}/items"
      end
      it 'returns successfully' do
        expect(response).to be_success
      end
      it 'returns empty' do
        expect(json.size).to eq(0) 
      end
    end
    
    context "when list and items present" do
      let!(:list) { 
        List.create(title: 'First List', status: 'Unstarted') 
      }
      let!(:items) { 
        list.items.create!(text: "First Item", status: "Unstarted")
        list.items.create!(text: "Second Item", status: "Unstarted")
      }

      before(:each) do
        get "/lists/#{list.id}/items"
      end
      
      it 'responds successfully' do
        expect(response).to be_success
      end
      it 'returns two items' do
        expect(json.size).to eq(2) 
      end
    end
  end
  describe "GET item" do
    context "when list does not exist" do
      it 'returns a 404 error' do
        get '/lists/abc/items/123'
        expect(response.status).to eq(404)
      end
    end
    context "when item does not exist" do
      let!(:list) { 
        List.create(title: 'First List', status: 'Unstarted') 
      }
      it 'returns a 404 error' do
        get '/lists/abc/items/123'
        expect(response.status).to eq(404)
      end
    end
    
    context "when item is present" do
      let!(:list) { 
        List.create(title: 'First List', status: 'Unstarted') 
      }
      let!(:items) { 
        [list.items.create!(text: "First Item", status: "Unstarted"),
        list.items.create!(text: "Second Item", status: "Unstarted")]
      }

      before(:each) do
        get "/lists/#{list.id}/items/#{items[1].id}"
      end
      
      it 'responds successfully' do
        expect(response).to be_success
      end
      it 'returns correct data' do
        expect(json).to include_json(
          id: items[1].id,
          list_id: list.id,
          text: "Second Item",
          status: "Unstarted"
        )
      end
    end
  end
  
  describe 'POST item' do
    context "without an associated list" do
      it "returns a 404 error" do
        post "/lists/abc/items", :item => {:text => "First Item", :status => "Unstarted"} 
        expect(response.status).to eq(404)
      end
    end
    context "with valid data" do
      let!(:list) { 
        List.create(title: 'First List', status: 'Unstarted') 
      }
      before(:each) do
        post "/lists/#{list.id}/items", :item => {:text => "First Item", :status => "Unstarted"} 
      end
      it 'responds successfully' do
        expect(response).to be_success
      end
      it 'populates database' do
        expect(Item.count).to eq(1)
        stored = Item.all[0]
        expect(stored.text).to eq("First Item")
        expect(stored.status).to eq("Unstarted")
        expect(stored.list_id).to eq(list.id)
      end
    end
    context "with invalid data" do
      let!(:list) { 
        List.create(title: 'First List', status: 'Unstarted') 
      }
      before(:each) do
        post "/lists/#{list.id}/items", :item => {:status => "Unstarted"} 
      end
      it 'fails' do
        expect(response.status).to eq(422)
      end
    end
  end

    
  describe 'PUT item' do
    let!(:list) { 
      List.create(title: 'First List', status: 'Unstarted') 
    }
    let!(:item) { 
      list.items.create!(text: "First Item", status: "Unstarted")
    }
    context "when modifying existing item" do
      before(:each) do
        put "/lists/#{list.id}/items/#{item.id}", :item => {:text => "First Item", :status => "Started"} 
      end
      it 'responds successfully' do
        expect(response).to be_success
      end
      it 'populates database' do
        expect(Item.count).to eq(1)
        stored = Item.all[0]
        expect(stored.text).to eq("First Item")
        expect(stored.status).to eq("Started")
        expect(stored.id).to eq(item.id)
        expect(stored.list_id).to eq(list.id)
      end
    end
    context "when modifying non-existent item" do
      it "responds with a 404 error" do
        put "/lists/#{list.id}/items/abc", :item => {:text => "First Item", :status => "Started"} 
        expect(response.status).to eq(404)
      end
    end
    context "with partial data" do
      before(:each) do
        put "/lists/#{list.id}/items/#{item.id}", :item => {:status => "Paused"} 
      end
      it "responds successfully" do
        expect(response).to be_success
      end
      it "preserves past data" do
        expect(Item.count).to eq(1)
        stored = Item.all[0]
        expect(stored.text).to eq("First Item")
        expect(stored.id).to eq(item.id)
      end
      it "updates data" do
        expect(Item.count).to eq(1)
        stored = Item.all[0]
        expect(stored.status).to eq("Paused")
      end
    end
  end
  
  describe "DELETE items" do
    context "when list does not exist" do
      it "responds with a 404 error" do
        delete "/lists/abc/items/abc"
        expect(response.status).to eq(404)
      end
    end
    context "when item does not exist" do
      let!(:list) { 
        List.create(title: 'First List', status: 'Unstarted') 
      }
      it "responds with a 404 error" do
        delete "/lists/#{list.id}/items/abc"
        expect(response.status).to eq(404)
      end
    end
    context "when item exists" do
      let!(:list) { 
        List.create(title: 'First List', status: 'Unstarted') 
      }
      let!(:item) { 
        list.items.create!(text: "First Item", status: "Unstarted")
      }
      before(:each) do 
        delete "/lists/#{list.id}/items/#{item.id}"
      end
      it "responds successfully" do
        expect(response).to be_success
      end
      it "deletes the record" do
        expect(Item.count).to eq(0)
        expect(List.count).to eq(1)
      end
    end
  end 
end