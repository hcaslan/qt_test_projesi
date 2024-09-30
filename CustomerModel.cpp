#include "CustomerModel.h"
#include <QJsonArray>
#include <QJsonDocument>
#include <QFile>

CustomerModel::CustomerModel(QObject *parent)
    : QAbstractListModel(parent), selectedCustomerIndex(-1) {}

int CustomerModel::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent)
    return customers.size();
}

QVariant CustomerModel::data(const QModelIndex &index, int role) const {
    if (index.row() < 0 || index.row() >= customers.size())
        return QVariant();

    const Customer &customer = customers[index.row()];

    if (role == CustomerIdRole)
        return customer.id;
    else if (role == CarsRole) {
        QStringList carList;
        for (const Car &car : customer.cars) {
            carList.append(car.model + " (" + QString::number(car.airbags) + " airbags)");
        }
        return carList.join(", ");
    }
    return QVariant();
}

QHash<int, QByteArray> CustomerModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[CustomerIdRole] = "customerId";
    roles[CarsRole] = "cars";
    return roles;
}

void CustomerModel::addCustomer(const QString &customerId) {
    if (!customerExists(customerId)) {
        beginInsertRows(QModelIndex(), customers.size(), customers.size());
        customers.append(Customer(customerId));
        endInsertRows();
    } else {
        emit errorOccurred("Customer with ID '" + customerId + "' already exists!");
    }
}

bool CustomerModel::customerExists(const QString &customerId) const {
    for (const Customer &customer : customers) {
        if (customer.id == customerId) {
            return true;
        }
    }
    return false;
}

void CustomerModel::selectCustomer(int index) {
    if (index >= 0 && index < customers.size()) {
        selectedCustomerIndex = index;
    }
}

void CustomerModel::addCarToCustomer(const QString &model, int airbags) {
    if (selectedCustomerIndex >= 0 && selectedCustomerIndex < customers.size()) {
        customers[selectedCustomerIndex].addCar(model, airbags);
        emit dataChanged(index(selectedCustomerIndex), index(selectedCustomerIndex));
    }
}

QString CustomerModel::getSelectedCustomerId() const {
    if (selectedCustomerIndex >= 0 && selectedCustomerIndex < customers.size()) {
        return customers[selectedCustomerIndex].id;
    }
    return QString();
}

// Saving and loading methods
void CustomerModel::saveToFile(const QString &filePath) {
    QJsonArray customerArray;
    for (const Customer &customer : customers) {
        customerArray.append(customer.toJson());
    }

    QJsonDocument doc(customerArray);
    QFile file(filePath);
    if (file.open(QIODevice::WriteOnly)) {
        file.write(doc.toJson());
        file.close();
    }
}

void CustomerModel::loadFromFile(const QString &filePath) {
    QFile file(filePath);
    if (file.open(QIODevice::ReadOnly)) {
        QByteArray jsonData = file.readAll();
        QJsonDocument doc = QJsonDocument::fromJson(jsonData);
        if (doc.isArray()) {
            QJsonArray customerArray = doc.array();
            for (const QJsonValue &value : customerArray) {
                QJsonObject customerObj = value.toObject();
                Customer customer(customerObj["id"].toString());
                QJsonArray carArray = customerObj["cars"].toArray();
                for (const QJsonValue &carValue : carArray) {
                    QJsonObject carObj = carValue.toObject();
                    customer.addCar(carObj["model"].toString(), carObj["airbags"].toInt());
                }
                customers.append(customer);
            }
        }
        file.close();
    }
}
