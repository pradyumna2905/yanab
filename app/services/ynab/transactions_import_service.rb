module YNAB
  class TransactionsImportService < YNAB::BaseService
    attr_reader :current_user

    def execute!
      current_user.budgets.each do |budget|
        budget.accounts.each do |account|
          transactions_response = client.transactions.get_transactions_by_account(
            budget.ynab_id,
            account.ynab_id
          )
          transactions = transactions_response.data.transactions

          transactions.each do |transaction|
            Transactions::CreateService.new(
              account,
              transaction_params(transaction)
            ).execute
          end
        end
      end
    end

    private

    def transaction_params(transaction)
      {
        date: transaction.date,
        amount: transaction.amount,
        cleared: transaction.cleared,
        approved: transaction.approved,
        deleted: transaction.deleted
      }
    end
  end
end