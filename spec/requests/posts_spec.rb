require 'rails_helper'
require 'byebug'

RSpec.describe 'Posts', type: :request do

  describe 'GET /posts' do
    let!(:user) { create(:user) }
    let!(:posts) { create_list(:post, 10, published: true, user: user) }

    it 'should return OK' do
      get '/posts'
      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(response).to have_http_status(:ok)
    end

    describe 'filters' do
      let!(:init_post) { create(:published_post, title: 'init_post', user: user) }
      let!(:last_post) { create(:published_post, title: 'last_post', user: user) }

      it 'should filter posts by title' do
        get '/posts?search=init_post'
        payload = JSON.parse(response.body)
        expect(payload).not_to be_empty
        expect(payload.size).to eq(1)
        expect(payload.map { |p| p['id'] }.sort).to eq([init_post.id])
        expect(response).to have_http_status(:ok)
      end
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
      expect(payload['title']).to eq(post.title)
      expect(payload['content']).to eq(post.content)
      expect(payload['author']['name']).to eq(user.name)
      expect(payload['author']['email']).to eq(user.email)
      expect(payload['author']['id']).to eq(user.id)
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

end
