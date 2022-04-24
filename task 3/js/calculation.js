function calculation(rate, sum, months) {
    let i = rate / 100 / 12
    let temp = Math.pow(1 + i, months)
    let k = i * temp / (temp - 1)
    let payment = (k * sum).toFixed(2)

    let dutyByPercents, mainDuty
    
    console.log("# month | payment | main duty | percents duty | main duty left")
    let month = 1

    while (sum > 0) {

        dutyByPercents = (i * sum).toFixed(2)
        mainDuty = (payment - dutyByPercents).toFixed(2)

        sum -= mainDuty
        let res = (sum < 0 ? 0 : sum).toFixed(2) 
        console.log(`${month++} | ${payment} | ${mainDuty} | ${dutyByPercents} | ${res}`)

    }

}