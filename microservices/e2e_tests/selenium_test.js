const { Builder, By, Key, until } = require('selenium-webdriver');

async function testMicroservicesApp() {
    let driver = await new Builder().forBrowser('chrome').build();
    try {
        // Navigate to the Home page
        await driver.get('http://10.0.0.4:8080');
        //await driver.wait(until.titleIs('Your Page Title'), 10000); 

        // Validate Home Page
        let homeText = await driver.findElement(By.css('Typography')).getText();
        console.assert(homeText.includes('Welcome to the Fancy Store!'), 'Home page text not found');

        // Navigate to the Orders page
        await driver.findElement(By.linkText('Orders')).click(); // Replace with actual text or identifier
        await driver.wait(until.elementLocated(By.css('Table')), 10000); // Wait for the table to load

        // Validate Orders Page
        let ordersTable = await driver.findElement(By.css('Table'));
        console.assert(ordersTable.isDisplayed(), 'Orders table not displayed');

        // Navigate to the Products page
        await driver.findElement(By.linkText('Products')).click(); // Replace with actual text or identifier
        await driver.wait(until.elementLocated(By.css('Grid')), 10000); // Wait for the grid to load

        // Validate Products Page
        let productsGrid = await driver.findElement(By.css('Grid'));
        console.assert(productsGrid.isDisplayed(), 'Products grid not displayed');

    } finally {
        await driver.quit();
    }
}
testMicroservicesApp();
