#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QStandardPaths>
#include <QQmlContext>
#include "CustomerModel.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    CustomerModel customerModel;

    QString filePath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/customer_data.json";

    customerModel.loadFromFile(filePath);

    engine.rootContext()->setContextProperty("customerModel", &customerModel);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("qt_test_projesi", "Main");

    QObject::connect(&app, &QGuiApplication::aboutToQuit, [&]() {
        customerModel.saveToFile(filePath);
    });

    return app.exec();
}
