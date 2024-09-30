#ifndef CUSTOMER_H
#define CUSTOMER_H

#include "Car.h"
#include <QObject>
#include <QString>
#include <QList>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QFile>

class Customer {
public:
    QString id;
    QList<Car> cars;

    Customer(QString id) : id(id) {}

    void addCar(QString model, int airbags) {
        cars.append(Car(model, airbags));
    }

    QJsonObject toJson() const {
        QJsonObject customerObj;
        customerObj["id"] = id;
        QJsonArray carsArray;
        for (const Car &car : cars) {
            carsArray.append(car.toJson());
        }
        customerObj["cars"] = carsArray;
        return customerObj;
    }
};

#endif // CUSTOMER_H
