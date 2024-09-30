#ifndef CAR_H
#define CAR_H

#include <QObject>
#include <QString>
#include <QList>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QFile>

class Car {
public:
    QString model;
    int airbags;

    Car(QString model, int airbags) : model(model), airbags(airbags) {}

    QJsonObject toJson() const {
        QJsonObject carObj;
        carObj["model"] = model;
        carObj["airbags"] = airbags;
        return carObj;
    }
};

#endif // CUSTOMER_H
