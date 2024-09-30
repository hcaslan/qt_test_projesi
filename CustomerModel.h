#ifndef CUSTOMERMODEL_H
#define CUSTOMERMODEL_H

#include <QAbstractListModel>
#include <QList>
#include "Customer.h"

class CustomerModel : public QAbstractListModel {
    Q_OBJECT

public:
    enum CustomerRoles {
        CustomerIdRole = Qt::UserRole + 1,
        CarsRole
    };

    explicit CustomerModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void addCustomer(const QString &customerId);
    Q_INVOKABLE bool customerExists(const QString &customerId) const;
    Q_INVOKABLE void selectCustomer(int index);
    Q_INVOKABLE void addCarToCustomer(const QString &model, int airbags);
    Q_INVOKABLE QString getSelectedCustomerId() const;

    // Saving and loading methods
    void saveToFile(const QString &filePath);
    void loadFromFile(const QString &filePath);

signals:
    void errorOccurred(const QString &errorMessage);  // Signal for error handling

private:
    QList<Customer> customers;
    int selectedCustomerIndex;
};

#endif // CUSTOMERMODEL_H
