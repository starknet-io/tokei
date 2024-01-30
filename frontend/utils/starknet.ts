export const  feltToString= (felt:BigInt) => {
    const newStrB = Buffer.from(felt.toString(16), 'ascii')
    return newStrB.toString()
  }

  export const  feltToAddress= (felt:BigInt) => {
    const newStrB = Buffer.from(felt.toString(16), 'ascii')
    return `0x${newStrB.toString()}`
  }