module API
  module V1
    class CardsAPI < Grape::API
      helpers API::Helpers::Auth

      helpers do
        def card_interactor
          @card_interactor ||= CardInteractor.new
        end

        def card_repository
          @card_repository ||= CardRepository.new
        end
      end

      resource :cards do
        desc "Return a list of cards"
        get "/" do
          validate_api_key
          cards = card_repository.find_by_user(current_user)
          present cards, with: API::V1::Entities::Card
        end

        desc "Create a new card"
        params do
          requires :name, type: String, allow_blank: false
          requires :tasks, type: Array[Task]
        end
        post "/" do
          validate_api_key

          name = params[:name]
          tasks = params[:tasks].map do |task|
            task_name = task[:name] || "Add a title"
            Task.new(name: task_name, status: :todo)
          end

          card = card_interactor.create(current_user, name, tasks: tasks)
          present card, with: API::V1::Entities::Card
        end
      end
    end
  end
end
