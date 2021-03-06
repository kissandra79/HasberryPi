{-# LINE 1 "HasberryPi.hsc" #-}

{-# LINE 2 "HasberryPi.hsc" #-}
{-# LANGUAGE CPP, ForeignFunctionInterface #-}

module HasberryPi where

import Foreign
import Foreign.C.Types


{-# LINE 10 "HasberryPi.hsc" #-}

--AUTHOR : AJJAI CHANDRA
--DATE   : March 3 2013

--TODO
-- * Make the calls unsafe. By default they are safe.
-- * I prematurely used 'C' types as fields in the Haskell types Wpimode, Pinmode and few more. 
--   Should change them to use proper Int types.
-- * Make a type for wiringPi Pin number and the GPIO pin numbers maybe
-- * Do I need to do 'freeHaskellFunPtr' for the function wiringPiISR?

--Macro Constants
newtype Wpimode = Wpimode {getWpiMode :: CInt} deriving (Show, Eq)
pins :: Wpimode
pins = Wpimode 0
{-# LINE 25 "HasberryPi.hsc" #-}

gpio :: Wpimode
gpio = Wpimode 1
{-# LINE 28 "HasberryPi.hsc" #-}

gpio_sys :: Wpimode
gpio_sys = Wpimode 2
{-# LINE 31 "HasberryPi.hsc" #-}

piface :: Wpimode
piface = Wpimode 3
{-# LINE 34 "HasberryPi.hsc" #-}

uninit :: Wpimode
uninit = Wpimode (-1)
{-# LINE 37 "HasberryPi.hsc" #-}


newtype Pinmode = Pinmode {getPinMode :: CInt} deriving (Show, Eq)
input :: Pinmode
input = Pinmode 0
{-# LINE 42 "HasberryPi.hsc" #-}

output :: Pinmode
output = Pinmode 1
{-# LINE 45 "HasberryPi.hsc" #-}

pwm_output :: Pinmode
pwm_output = Pinmode 2
{-# LINE 48 "HasberryPi.hsc" #-}

gpio_clock :: Pinmode
gpio_clock = Pinmode 3
{-# LINE 51 "HasberryPi.hsc" #-}


newtype PinSignal = PinSignal {getPinSignal :: CInt} deriving (Show, Eq)
pinhigh :: PinSignal
pinhigh = PinSignal 1
{-# LINE 56 "HasberryPi.hsc" #-}

pinlow :: PinSignal
pinlow = PinSignal 0
{-# LINE 59 "HasberryPi.hsc" #-}


newtype PullResistor = PullResistor {getPullResistor :: CInt} deriving (Show, Eq)
pull_up :: PullResistor
pull_up = PullResistor 2
{-# LINE 64 "HasberryPi.hsc" #-}

pull_down :: PullResistor
pull_down = PullResistor 1
{-# LINE 67 "HasberryPi.hsc" #-}

pull_off:: PullResistor
pull_off = PullResistor 0
{-# LINE 70 "HasberryPi.hsc" #-}


newtype PwmMode = PwmMode {getPwmMode :: CInt} deriving (Show, Eq)
pwm_ms :: PwmMode
pwm_ms = PwmMode 0
{-# LINE 75 "HasberryPi.hsc" #-}

pwm_bal :: PwmMode
pwm_bal = PwmMode 1
{-# LINE 78 "HasberryPi.hsc" #-}


newtype InterruptLvl = InterruptLvl {getInterruptLvl :: CInt} deriving (Show, Eq)
edge_setup :: InterruptLvl 
edge_setup = InterruptLvl 0
{-# LINE 83 "HasberryPi.hsc" #-}

edge_falling :: InterruptLvl 
edge_falling = InterruptLvl 1
{-# LINE 86 "HasberryPi.hsc" #-}

edge_rising :: InterruptLvl 
edge_rising = InterruptLvl 2
{-# LINE 89 "HasberryPi.hsc" #-}

edge_both :: InterruptLvl 
edge_both = InterruptLvl 3
{-# LINE 92 "HasberryPi.hsc" #-}

--Basic wiringPi Functions
foreign import ccall "wiringPi.h wiringPiSetup" c_wiringPiSetup :: IO CInt
wiringPiSetup :: IO Int
wiringPiSetup = fmap fromIntegral c_wiringPiSetup

foreign import ccall "wiringPi.h wiringPiSetupSys" c_wiringPiSetupSys :: IO CInt
wiringPiSetupSys :: IO Int
wiringPiSetupSys = fmap fromIntegral c_wiringPiSetupSys

foreign import ccall "wiringPi.h wiringPiSetupGpio" c_wiringPiSetupGpio :: IO CInt
wiringPiSetupGpio :: IO Int 
wiringPiSetupGpio = fmap fromIntegral c_wiringPiSetupGpio

foreign import ccall "wiringPi.h wiringPiSetupPiFace" c_wiringPiSetupPiFace :: IO CInt
wiringPiSetupPiFace :: IO Int
wiringPiSetupPiFace = fmap fromIntegral c_wiringPiSetupPiFace

foreign import ccall "wiringPi.h piBoardRev" c_piBoardRev :: IO CInt
piBoardRev :: IO Int
piBoardRev = fmap fromIntegral c_piBoardRev

foreign import ccall "wiringPi.h wpiPinToGpio" c_wpiPinToGpio :: CInt -> IO CInt
wpiPinToGpio :: Int -> IO Int
wpiPinToGpio wpin = fmap fromIntegral (c_wpiPinToGpio $ fromIntegral wpin)

type TwoIntToVoid = (CInt -> CInt -> IO ())
type TwoIntToInt = (CInt -> CInt -> IO CInt)
type IntToInt = (CInt -> IO CInt)
type IntToVoid = (CInt -> IO ())
type UIntToVoid = (CUInt -> IO ())

foreign import ccall "wiringPi.h &pinMode" c_pinMode :: Ptr (FunPtr TwoIntToVoid)
foreign import ccall "dynamic" dc_pinMode :: FunPtr TwoIntToVoid -> TwoIntToVoid
pinMode :: Int -> Pinmode -> IO ()
pinMode pin (Pinmode m) = do fn <- peek c_pinMode 
                             (dc_pinMode fn) (fromIntegral pin) m

foreign import ccall "wiringPi.h &getAlt" c_getAlt :: Ptr (FunPtr IntToInt)
foreign import ccall "dynamic" dc_getAlt :: FunPtr IntToInt -> IntToInt
getAlt :: Int -> IO Int
getAlt pin = do fn <- peek c_getAlt 
                fmap fromIntegral ((dc_getAlt fn) $ fromIntegral pin)

foreign import ccall "wiringPi.h &pullUpDnControl" c_pullUpDnControl :: Ptr (FunPtr TwoIntToVoid)
foreign import ccall "dynamic" dc_pullUpDnControl :: FunPtr TwoIntToVoid -> TwoIntToVoid
pullUpDnControl :: Int -> PullResistor -> IO ()
pullUpDnControl pin (PullResistor pud) = do fn <- peek c_pullUpDnControl
                                            let fn' = dc_pullUpDnControl fn
                                            fn' (fromIntegral pin) pud

foreign import ccall "wiringPi.h &digitalWrite" c_digitalWrite :: Ptr (FunPtr TwoIntToVoid)
foreign import ccall "dynamic" dc_digitalWrite :: FunPtr TwoIntToVoid -> TwoIntToVoid
digitalWrite :: Int -> PinSignal -> IO ()
digitalWrite pin (PinSignal val) = do fn <- peek c_digitalWrite 
                                      (dc_digitalWrite fn) (fromIntegral pin) val

foreign import ccall "wiringPi.h &digitalWriteByte" c_dWB :: Ptr (FunPtr IntToVoid)
foreign import ccall "dynamic" dc_dWB :: FunPtr IntToVoid -> IntToVoid
digitalWriteByte :: Int -> IO ()
digitalWriteByte val = do fn <- peek c_dWB
                          (dc_dWB fn) (fromIntegral val)

foreign import ccall "wiringPi.h &gpioClockSet" c_gCS :: Ptr (FunPtr TwoIntToVoid)
foreign import ccall "dynamic" dc_gCS :: FunPtr TwoIntToVoid -> TwoIntToVoid
gpioClockSet :: Int -> Int -> IO ()
gpioClockSet pin freq = do fn <- peek c_gCS
			   (dc_gCS fn) (fromIntegral pin) (fromIntegral freq)

foreign import ccall "wiringPi.h &pwmWrite" c_pwmW :: Ptr (FunPtr TwoIntToVoid)
foreign import ccall "dynamic" dc_pwmW :: FunPtr TwoIntToVoid -> TwoIntToVoid
pwmWrite :: Int -> Int -> IO ()
pwmWrite pin value = do fn <- peek c_pwmW
                        (dc_pwmW fn) (fromIntegral pin) (fromIntegral value)

foreign import ccall "wiringPi.h &setPadDrive" c_sPD :: Ptr (FunPtr TwoIntToVoid)
foreign import ccall "dynamic" dc_sPD :: FunPtr TwoIntToVoid -> TwoIntToVoid
setPadDrive :: Int -> Int -> IO ()
setPadDrive group val = do fn <- peek c_sPD
                           (dc_sPD fn) (fromIntegral group) (fromIntegral val)

foreign import ccall "wiringPi.h &digitalRead" c_digitalRead :: Ptr (FunPtr IntToInt)
foreign import ccall "dynamic" dc_digitalRead :: FunPtr IntToInt -> IntToInt
digitalRead :: Int -> IO PinSignal
digitalRead pin = do fn <- peek c_digitalRead
                     let fn' = dc_digitalRead fn
                     signal <- fn' $ fromIntegral pin
                     if signal == (fromIntegral $ getPinSignal pinhigh)
			 then return pinhigh
                         else return pinlow

foreign import ccall "wiringPi.h &pwmSetMode" c_pwmSM :: Ptr (FunPtr IntToVoid)
foreign import ccall "dynamic" dc_pwmSM :: FunPtr IntToVoid -> IntToVoid
pwmSetMode :: PwmMode -> IO ()
pwmSetMode (PwmMode mode) = do fn <- peek c_pwmSM
                               (dc_pwmSM fn) mode


foreign import ccall "wiringPi.h &pwmSetRange" c_pwmSR :: Ptr (FunPtr UIntToVoid)
foreign import ccall "dynamic" dc_pwmSR :: FunPtr UIntToVoid -> UIntToVoid
-- The range must be an unsigned integer
pwmSetRange :: Int -> IO ()
pwmSetRange range = do fn <- peek c_pwmSR
                       (dc_pwmSR fn) (fromIntegral range)

foreign import ccall "wiringPi.h &pwmSetClock" c_pwmSC :: Ptr (FunPtr IntToVoid)
foreign import ccall "dynamic" dc_pwmSC :: FunPtr IntToVoid -> IntToVoid
pwmSetClock :: Int -> IO ()
pwmSetClock divisor = do fn <- peek c_pwmSC
                         (dc_pwmSC fn) (fromIntegral divisor)

--Interrupt Handling
-- waitForInterrupt has been deprecated in the C wiringPi library
foreign import ccall "wiringPi.h &waitForInterrupt" c_wFI :: Ptr (FunPtr TwoIntToInt)
foreign import ccall "dynamic" dc_wFI :: FunPtr TwoIntToInt -> TwoIntToInt
waitForInterrupt :: Int -> Int -> IO Int
waitForInterrupt pin mS = do fn <- peek c_wFI
                             fmap fromIntegral ((dc_wFI fn) (fromIntegral pin) (fromIntegral mS))

foreign import ccall "wiringPi.h wiringPiISR" c_wPISR :: CInt -> CInt -> FunPtr (IO ()) -> IO ()
foreign import ccall "wrapper" wc_wPISR :: IO () -> IO (FunPtr (IO ()))
wiringPiISR :: Int -> InterruptLvl -> IO () -> IO ()
wiringPiISR pin (InterruptLvl il) fntocall = do fn <- wc_wPISR fntocall
                                                let cpin = fromIntegral pin
                                                c_wPISR cpin il fn

--Scheduling priority
foreign import ccall "wiringPi.h piHiPri" c_pHP :: CInt -> IO CInt
piHiPri :: Int -> IO Int
piHiPri priority = fmap fromIntegral (c_pHP (fromIntegral priority))

--Extras from arduino land

-- howlong is an unsigned integer
foreign import ccall "wiringPi.h delay" c_delay :: UIntToVoid
delay :: Int -> IO ()
delay howlong = c_delay (fromIntegral howlong)

-- howlong is an unsigned integer
foreign import ccall "wiringPi.h delayMicroseconds" c_dMs :: UIntToVoid
delayMicroseconds :: Int -> IO ()
delayMicroseconds howlong = c_dMs (fromIntegral howlong)

foreign import ccall "wiringPi.h millis" c_millis :: IO CUInt
millis :: IO Int
millis = fmap fromIntegral c_millis

foreign import ccall "wiringPi.h micros" c_micros :: IO CUInt
micros :: IO Int
micros = fmap fromIntegral c_micros

