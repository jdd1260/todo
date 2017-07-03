require 'rails_helper'
require 'rspec/json_expectations'

describe "Lists API" do
  describe "GET lists" do
    context "when empty" do
      before(:each) do
        get '/lists'
      end
      it 'returns successfully' do
        expect(response).to be_success
      end
      it 'returns empty' do
        expect(json.size).to eq(0) 
      end
    end
    
    context "when lists present" do
      let!(:list) { 
        List.create(title: 'First List', status: 'Unstarted') 
        List.create(title: 'Second List', status: 'Unstarted') 
      }

      before(:each) do
        get '/lists'
      end
      
      it 'responds successfully' do
        expect(response).to be_success
      end
      it 'returns two items' do
        expect(json.size).to eq(2) 
      end
    end
  end
  
  describe "GET list" do
    context "when list does not exist" do
      it 'returns a 404 error' do
        get '/lists/abc'
        expect(response.status).to eq(404)
      end
    end
    
    context "when list is present" do
      let!(:list) { 
        List.create(title: 'First List', status: 'Unstarted') 
      }

      before(:each) do
        get "/lists/#{list.id}"
      end
      
      it 'responds successfully' do
        expect(response).to be_success
      end
      it 'returns correct data' do
        expect(json).to include_json(
          id: list.id,
          title: "First List",
          status: "Unstarted"
        )
      end
    end
  end
  
  describe 'POST list' do
    context "with valid data" do
      before(:each) do
        post "/lists", :list => {:title => "First List", :status => "Unstarted"} 
      end
      it 'responds successfully' do
        expect(response).to be_success
      end
      it 'populates database' do
        expect(List.count).to eq(1)
        stored = List.all[0]
        expect(stored.title).to eq("First List")
        expect(stored.status).to eq("Unstarted")
      end
    end
    context "with invalid data" do
      before(:each) do
        post "/lists", :list => {:status => "Unstarted"} 
      end
      it 'fails' do
        expect(response.status).to eq(422)
      end
    end
  end
  
    
  describe 'PUT list' do
    let!(:list) { 
      List.create(title: 'First List', status: 'Unstarted') 
    }
    context "when modifying existing list" do
      before(:each) do
        put "/lists/#{list.id}", :list => {:title => "First List", :status => "Started"} 
      end
      it 'responds successfully' do
        expect(response).to be_success
      end
      it 'populates database' do
        expect(List.count).to eq(1)
        stored = List.all[0]
        expect(stored.title).to eq("First List")
        expect(stored.status).to eq("Started")
        expect(stored.id).to eq(list.id)
      end
    end
    context "when modifying non-existent list" do
      it "responds with a 404 error" do
        put "/lists/abc", :list => {:title => "First List", :status => "Started"} 
        expect(response.status).to eq(404)
      end
    end
    context "with partial data" do
      before(:each) do
        put "/lists/#{list.id}", :list => {:status => "Paused"} 
      end
      it "responds successfully" do
        expect(response).to be_success
      end
      it "preserves past data" do
        expect(List.count).to eq(1)
        stored = List.all[0]
        expect(stored.title).to eq("First List")
        expect(stored.id).to eq(list.id)
      end
      it "updates data" do
        expect(List.count).to eq(1)
        stored = List.all[0]
        expect(stored.status).to eq("Paused")
      end
    end
  end
  describe "DELETE lists" do
    let!(:list) { 
      List.create(title: 'First List', status: 'Unstarted') 
    }
    let!(:item) { 
      list.items.create!(text: "First Item", status: "Unstarted")
    }
    context "when list does not exist" do
      it "responds with a 404 error" do
        delete "/lists/abc"
        expect(response.status).to eq(404)
      end
    end
    context "when list exists" do
      before(:each) do 
        delete "/lists/#{list.id}"
      end
      it "responds successfully" do
        expect(response).to be_success
      end
      it "deletes the record" do
        expect(List.count).to eq(0)
      end
      it "deletes the child items" do
        expect(Item.count).to eq(0)
      end
    end
  end
end