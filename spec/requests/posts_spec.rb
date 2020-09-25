require 'rails_helper'
require 'byebug'

RSpec.describe 'Posts', type: :request do

  describe 'GET /posts' do
    let!(:user) { create(:user) }
    let!(:posts) { create_list(:post, 10, published: true, user: user) }
    before { get '/posts' }

    it 'should return OK' do
      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'with data in database' do
    let!(:user) { create(:user) }
    let!(:posts) { create_list(:post, 10, published: true, user: user) }
    before { get '/posts' }

    it 'should return all the published posts' do
      payload = JSON.parse(response.body)
      expect(payload.size).to eq(posts.size)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /posts/{id}' do
    let(:user) { create(:user) }
    let(:post) { create(:post, user: user) }

    it 'should return a post' do
      get "/posts/#{post.id}"
      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload['id']).to eq(post.id)
      expect(response).to have_http_status(:ok)
    end

    it 'should return a 404' do
      get "/posts/0"
      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload['error']).not_to be_empty
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /posts' do
    let!(:user) { create(:user) }

    it 'should create post' do
      data = {
        post: {
          title: 'title',
          content: 'content',
          published: false,
          user_id: user.id
        }
      }
      post '/posts', params: data
      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload['id']).not_to be_nil
      expect(response).to have_http_status(:created)
    end

    it 'should return error message on invalid create post' do
      data = {
        post: {
          content: 'content',
          published: false,
          user_id: user.id
        }
      }
      post '/posts', params: data
      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload['error']).not_to be_empty
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PUT /posts/{id}' do
    let(:user) { create(:user) }
    let!(:post) { create(:post, user: user) }

    it 'should update post' do
      data = {
        post: {
          id: post.id,
          title: 'title',
          content: 'content',
          published: true,
          user_id: user.id
        }
      }

      put "/posts/#{post.id}", params: data

      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload['id']).to eq(post.id)
      expect(payload['title']).to eq('title')
      expect(response).to have_http_status(:ok)
    end

    it 'should return error message on invalid update post' do
      data = {
        post: {
          title: nil,
          content: nil,
          published: true
        }
      }

      put "/posts/#{post.id}", params: data

      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload['error']).not_to be_empty
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'should return a 404' do
      data = {
        post: {
          id: post.id,
          title: 'title',
          content: 'content',
          published: true,
          user_id: user.id
        }
      }
      put "/posts/0", params: data
      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload['error']).not_to be_empty
      expect(response).to have_http_status(:not_found)
    end
  end

end
