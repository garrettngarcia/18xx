# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1841
      module Step
        class BuyNewTokens < Engine::Step::Base
          def actions(entity)
            return [] unless entity == pending_entity

            %w[choose]
          end

          def active?
            pending_entity
          end

          def current_entity
            pending_entity
          end

          def pending_entity
            pending_buy[:entity]
          end

          def pending_price
            pending_buy[:price]
          end

          def pending_first_price
            pending_buy[:first_price]
          end

          def pending_type
            pending_buy[:type]
          end

          def pending_min
            pending_buy[:min]
          end

          def pending_max
            pending_buy[:max]
          end

          def pending_buy
            @round.buy_tokens&.first || {}
          end

          def description
            'Buy New Tokens'
          end

          def process_choose(action)
            num = action.choice.to_i
            total = price(num)
            type = pending_type
            entity = pending_entity
            price = pending_price
            @round.buy_tokens.shift

            case type
            when :start
              @game.purchase_tokens!(entity, num, price)
            when :transform
              @game.purchase_additional_tokens!(entity, num, total)
              @game.transform_finish
            end
          end

          def choice_available?(entity)
            pending_entity == entity
          end

          def choice_name
            return 'Number of Additional Tokens to Buy' if pending_type != :start

            'Number of Tokens to Buy'
          end

          def price(num)
            return 0 if num.zero?

            pending_first_price + ((num - 1) * pending_price)
          end

          def choices
            Array.new(pending_max - pending_min + 1) do |i|
              num = i + pending_min
              total = price(num)
              next if (num > pending_min) && (total > pending_entity.cash)

              emr = total > pending_entity.cash ? ' - EMR' : ''

              [num, "#{num} (#{@game.format_currency(total)}#{emr})"]
            end.compact.to_h
          end

          def visible_corporations
            [pending_entity]
          end

          def round_state
            super.merge(
              {
                buy_tokens: [],
              }
            )
          end
        end
      end
    end
  end
end
