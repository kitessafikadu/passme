import { useForm, Controller } from "react-hook-form";
import ReactDatePicker from "react-datepicker";
import "react-datepicker/dist/react-datepicker.css";
import { useSession } from "next-auth/react";
import { useCreateFlightMutation } from "@/app/services/flightsApi";
import turkishquestions from "../../../../turkish";
import flight from "../../../../flight";
import { Translations } from "../../../../flight";


interface FormComponentProps {
  questions: any;
  questionsAmharic: any;
  handleedit: (data: any) => void;
  handlethepop: (data: any) => void;
  popup: boolean;
  lanaguage: string;
  setPopup: (value: boolean) => void;
}

const FormComponent: React.FC<FormComponentProps> = ({
  lanaguage,
  questions,
  questionsAmharic,
  popup,
  setPopup,
  handleedit,
  handlethepop,
}) => {
  const { data: session, status } = useSession()
  interface FormDefaultValues {
    flightName: string;
    flightOrigin: string;
    flightDestination: string;
    flightDate: null;
    [key: string]: string | null;
  }

  const { control, handleSubmit, reset } = useForm<FormDefaultValues>({
    shouldUnregister: true,
    defaultValues: {
      flightName: "",
      flightOrigin: "",
      flightDestination: "",
      flightDate: null,
      ...(lanaguage === "english"
        ? Object.keys(questions).reduce<Record<string, string>>((acc, key) => {
          const questionKey = questions[parseInt(key)];
          acc[questionKey] = "";
          return acc;
        }, {})

        : Object.keys(questionsAmharic).reduce<Record<string, string>>((acc, key) => {
          const questionKey = questionsAmharic[parseInt(key)];
          acc[questionKey] = "";
          return acc;
        }, {}))
    }
  });

  const [createFlight, { isLoading: isCreating }] = useCreateFlightMutation();
  const onSubmitForm = async (data: any) => {
    const {
      flightName,
      flightOrigin,
      flightDestination,
      flightDate,
      ...qaFields
    } = data;

    const qa = Object.entries(qaFields).map(([question, answer]) => ({
      question,
      answer: (answer as string)
    }));

    try {
      await createFlight({
        title: flightName,
        from_country: flightOrigin,
        to_country: flightDestination,
        date: flightDate,
        // @ts-ignore
        user_id: session?.user?.id ?? '',
        language: lanaguage,
        qa,
      }
      ).unwrap();

      setPopup(false);
      reset();
    } catch (err) {
      console.error('Failed to create flight', err);
    }
  };



  const currentLang = (flight as Translations)[lanaguage as keyof Translations] || flight.english

  const triggerSubmit = handleSubmit(onSubmitForm);
  const validateInputByLanguage = (input: string, language: string): boolean => {
    const patterns: Record<string, RegExp> = {
      "english": /^[a-zA-Z0-9\s.,!?@#$%^&*()_+=-]+$/, // English + special characters
      "amharic": /^[\u1200-\u137F\s.,!?@#$%^&*()_+=-]+$/, // Amharic + special characters
      "turkish": /^[a-zA-ZçÇğĞıİöÖşŞüÜ\s.,!?@#$%^&*()_+=-]+$/, // Turkish + special characters
    };

    const pattern = patterns[language];
    if (!pattern) {
      console.error(`Unsupported language: ${language}`);
      return false;
    }

    return pattern.test(input);
  };

  return (
    <form onSubmit={(e) => e.preventDefault()} className="mx-auto w-[80%] md:w-[70%] mt-10 mb-8">

      <h1 className="text-white text-[25px] md:mb-6 sm:m-0">
        {currentLang.flightDetails}
      </h1>

      <div className="relative py-2 before:rounded-[10px] transition-transform duration-200 ease-in-out before:border-[2px] before:border-[#3927FF] hover:-translate-y-[2px] before:content-[''] before:absolute before:-inset-[2px] before:bg-[radial-gradient(circle_at_center,_#386BF62E_0%,_#386BF62E_100%)] before:opacity-0 before:transition-opacity before:duration-200 hover:before:opacity-100 before:-z-10 before:pointer-events-none">
        <div className="relative py-2">
          <p className="text-white text-[19px] font-bold font-inter mx-2">
            {currentLang.flightName}
          </p>
          <Controller
            name="flightName"
            control={control}
            rules={{
              required: currentLang.validation.Required,
              validate: (value) => (
                validateInputByLanguage(value, lanaguage) ||
                currentLang.validation.LettersOnly),
            }}
            render={({ field, fieldState: { error } }) => (
              <div className="relative px-2 py-4">
                <input
                  placeholder={currentLang.flightNamePlaceholder}
                  {...field}
                  className="w-full min-w-full h-[70px] px-4 py-4 rounded-[20px] bg-[#FFFFFF0D] text-white focus:outline-none transition-all duration-200"
                />
                {error && <p className="text-red-500">{error.message}</p>}
              </div>
            )}
          />
        </div>
      </div>

      {/* From/To Country */}
      <div className="flex flex-col justify-between md:flex-row w-full">
        {/* From Country */}
        <div className=" w-full md:w-[45%]  relative before:rounded-[10px] transition-transform duration-200 ease-in-out before:border-[2px] before:border-[#3927FF] hover:-translate-y-[2px] before:content-[''] before:absolute before:-inset-[2px] before:bg-[radial-gradient(circle_at_center,_#386BF62E_0%,_#386BF62E_100%)] before:opacity-0 before:transition-opacity before:duration-200 hover:before:opacity-100 before:-z-10 before:pointer-events-none">
          <p className="text-white text-[19px] font-bold font-inter mb-2 ml-2">
            {currentLang.fromCountry}
          </p>
          <Controller
            name="flightOrigin"
            control={control}

            rules={{
              required: currentLang.validation.Required,
              validate: (value) => (
                validateInputByLanguage(value, lanaguage) ||
                currentLang.validation.LettersOnly),

            }}
            render={({ field, fieldState: { error } }) => (
              <div className="w-full relative px-2 py-4 ">
                <input
                  {...field}
                  placeholder={currentLang.fromCountryPlaceholder}
                  className="w-full h-[74px] px-4 py-4 rounded-[20px] bg-[#FFFFFF0D] text-white focus:outline-none transition-all duration-200"
                />
                {error && <p className="text-red-500">{error.message}</p>}
              </div>
            )}
          />
        </div>

        {/* To Country */}
        <div className="w-full md:w-[45%]  relative before:rounded-[10px] transition-transform duration-200 ease-in-out before:border-[2px] before:border-[#3927FF] hover:-translate-y-[2px] before:content-[''] before:absolute before:-inset-[2px] before:bg-[radial-gradient(circle_at_center,_#386BF62E_0%,_#386BF62E_100%)] before:opacity-0 before:transition-opacity before:duration-200 hover:before:opacity-100 before:-z-10 before:pointer-events-none">
          <p className="text-white text-[19px] font-bold font-inter mb-2 ml-2">
            {currentLang.toCountry}
          </p>
          <Controller
            name="flightDestination"
            control={control}
            rules={{
              required: currentLang.validation.Required,
              validate: (value) => (
                validateInputByLanguage(value, lanaguage) ||
                currentLang.validation.LettersOnly),
            }}

            render={({ field, fieldState: { error } }) => (
              <div className="relative md:mr-32 w-full px-2 py-4">
                <input
                  {...field}
                  placeholder={currentLang.toCountryPlaceholder}

                  className="w-full h-[74px] px-4 py-4 rounded-[16px] bg-[#FFFFFF0D] text-white focus:outline-none transition-all duration-200"
                />
                {error && <p className="text-red-500 mt-2">{error.message}</p>}
              </div>
            )}
          />
        </div>
      </div>

      {/* Flight Date */}
      <div className="mb-10 w-full py-4 before:rounded-[10px] transition-transform duration-200 ease-in-out before:border-[2px] before:border-[#3927FF] hover:-translate-y-[2px] before:content-[''] before:absolute before:-inset-[2px] before:bg-[radial-gradient(circle_at_center,_#386BF62E_0%,_#386BF62E_100%)] before:opacity-0 before:transition-opacity before:duration-200 hover:before:opacity-100 before:-z-10 before:pointer-events-none">
        <p className="text-white text-[19px] font-bold font-inter mb-2 ml-2">
          {currentLang.flightDate}
        </p>
        <Controller
          name="flightDate"
          control={control}
          // rules={{
          //   required:currentLang.validation.Required,
          // }}

          render={({ field }) => (
            <div className="w-full  px-2 py-4">
              <ReactDatePicker
                selected={field.value ? new Date(field.value) : null}

                onChange={(date) => field.onChange(date?.toISOString())}
                showTimeSelect
                dateFormat="Pp"
                wrapperClassName="w-full"
                placeholderText={
                  currentLang.flightDatePlaceholder
                }
                className="w-full h-[74px] px-4 py-4 rounded-[16px] bg-[#FFFFFF0D] text-white focus:outline-none transition-all duration-200"
              />
            </div>
          )}
        />
      </div>

      <h1 className="text-white text-[24px] mb-10">{currentLang.commonQuestions}</h1>

      {lanaguage === "english" &&
        Object.keys(questions).map((key) => (
          <div
            key={key}
            className="relative  mb-6 overflow-visible  before:rounded-[10px] transition-transform duration-200 ease-in-out before:border-[2px] before:border-[#3927FF] hover:-translate-y-[2px] before:content-[''] before:absolute before:-inset-[2px] before:bg-[radial-gradient(circle_at_center,_#386BF62E_0%,_#386BF62E_100%)] before:opacity-0 before:transition-opacity before:duration-200 hover:before:opacity-100 before:-z-10 before:pointer-events-none"
          >
            <p>
              <span className="inline-block font-bold text-[19px] text-white font-inter m-2">
                <span className="text-[#3972FF] mr-2">{`${parseInt(key)} ,`}</span>
                {`${questions[parseInt(key)]}`}
              </span>
            </p>
            <Controller
              name={`${questions[parseInt(key)]}`}
              control={control}
              rules={{
                required: "This field is required",
                pattern: {
                  value: /^[a-zA-Z0-9\s.,!?@#$%^&*()_+=-]+$/,
                  message: "Please use English letters and numbers only.",
                },
              }}
              render={({ field, fieldState: { error } }) => (
                <div className="px-2 py-4 h-[100px]">
                  <input
                    {...field}
                    value={field.value || ''}
                    placeholder="enter your answer"
                    className=" w-full min-w-full h-[74px] px-4 py-4 rounded-[16px] bg-[#FFFFFF0D] text-white focus:outline-none"
                  />
                  {error && (
                    <p className="text-red-500 mt-2">{error.message}</p>
                  )}
                </div>
              )}
            />
          </div>
        ))}
      {lanaguage === "amharic" &&
        Object.keys(questionsAmharic).map((key) => (
          <div
            key={key}
            className="relative mb-6 overflow-visible before:rounded-[10px] transition-transform duration-200 ease-in-out before:border-[2px] before:border-[#3927FF] hover:-translate-y-[2px] before:content-[''] before:absolute before:-inset-[2px] before:bg-[radial-gradient(circle_at_center,_#386BF62E_0%,_#386BF62E_100%)] before:opacity-0 before:transition-opacity before:duration-200 hover:before:opacity-100 before:-z-10 before:pointer-events-none"
          >
            <p>
              <span className="inline-block font-bold text-[19px] text-white font-inter m-2">
                <span className="text-[#3972FF] mx-2">{`${parseInt(key)},`}</span>
                {questionsAmharic[parseInt(key)]}
              </span>
            </p>
            <Controller
              name={`${questionsAmharic[parseInt(key)]}`}
              control={control}
              rules={{
                required: "ይህን መሞላት አስፈላጊ ነው።",
                pattern: {
                  value: /^[\u1200-\u137F\s.,!?@#$%^&*()_+=-]+$/,
                  message: "ይቅርታ፣ እባኮትን የአማርኛ ፊደል በመጠቀም ይሞሉ።",
                },
              }}
              render={({ field, fieldState: { error } }) => (
                <div className="px-2 py-4">
                  <input
                    {...field}
                    value={field.value || ''}
                    placeholder="የአማርኛ ፊደል በመጠቀም ይሞሉ"
                    className="w-full min-w-full h-[74px] px-4 py-4 rounded-[16px] bg-[#FFFFFF0D] text-white focus:outline-none"
                  />
                  {error && (
                    <p className="text-red-500 mt-2">{error.message}</p>
                  )}
                </div>
              )}
            />
          </div>
        ))}


      {lanaguage === "turkish" &&
        Object.keys(turkishquestions).map((key) => (
          <div
            key={key}
            className="relative overflow-visible before:rounded-[10px] transition-transform duration-200 ease-in-out before:border-[2px] before:border-[#3927FF] hover:-translate-y-[2px] before:content-[''] before:absolute before:-inset-[2px] before:bg-[radial-gradient(circle_at_center,_#386BF62E_0%,_#386BF62E_100%)] before:opacity-0 before:transition-opacity before:duration-200 hover:before:opacity-100 before:-z-10 before:pointer-events-none"
          >
            <p>
              <span className="inline-block font-bold text-[19px] text-white font-inter m-2">
                <span className="text-[#3972FF] mx-2">{`${parseInt(key)},`}</span>
                {turkishquestions[parseInt(key)]}
              </span>
            </p>
            <Controller
              name={`${turkishquestions[parseInt(key)]}`}
              control={control}
              rules={{
                required: "Bu alanın doldurulması zorunludur.",
                pattern: {
                  value: /^[a-zA-ZçÇğĞıİöÖşŞüÜ\s.,!?@#$%^&*()_+=-]+$/, // Allows Turkish + Latin chars
                  message: "Lütfen yalnızca Türkçe karakterler kullanın.", // "Please use only Turkish characters."
                },
              }}
              render={({ field, fieldState: { error } }) => (
                <div className="px-2 py-4">
                  <input
                    {...field}
                    value={field.value || ''}
                    placeholder="Türkçe karakterler kullanın"
                    className="w-full min-w-full h-[74px] px-4 py-4 rounded-[16px] bg-[#FFFFFF0D] text-white focus:outline-none"
                  />
                  {error && (
                    <p className="text-red-500 mt-2">{error.message}</p>
                  )}
                </div>
              )}
            />
          </div>
        ))}

      <div className="flex justify-center items-center">
        <button
          type="button"
          onClick={handlethepop}

          className=" mt-10 w-full md:w-[141px] h-[40px]
          pt-[4px] pr-[39px] pb-[4px] pl-[39px]
          gap-[8px]
          rounded-[10px]
          flex items-center justify-center
          cursor-pointe
          border-none
          font-sans text-[14px] bg-[#FFFFFF] hover:bg-[#F0F0F0] text-[#3972FF] border border-[#FFFFFF]"
        >
          <p className="font-inter font-bold text-[18px] leading-[32px] tracking-normal text-center align-middle"> {currentLang.submitButton} </p>
        </button>
      </div>
      {popup && (
        <div className="fixed top-1/2 left-[calc(50%+var(--sidebar-width,0px)/2)] transform -translate-x-1/2 -translate-y-1/2 z-50 w-[90%] sm:w-[80%] md:w-[550px] bg-black bg-opacity-60 h-[300px] rounded-lg">
          <div className="flex w-full justify-center align-middle mt-20 text-white font-inter font-normal text-[23px] leading-[100%] tracking-[0] text-center">
            <p>{currentLang.confirmationQuestion}</p>
          </div>
          <div className="flex justify-center gap-4 mt-15">
            <button
              onClick={handleedit}
              className="bg-[#CCCCCC8C] hover:bg-[#4d4d4d] text-white w-40 h-10 rounded-[12px] border border-solid border-[rgba(255,255,255,0.1)] font-bold text-[10px] md:text-[15px] leading-[24px] text-center align-middle"
            >
              {currentLang.backToEdit}
            </button>
            <button
              type="button"
              onClick={triggerSubmit}
              className="bg-[#3972FF] border-[#3972FF] hover:bg-[#5C8BFF] text-white w-40 h-10 px-4 rounded-[12px] border border-solid mr-4 font-bold text-[15px] leading-[24px] text-center align-middle"
            >
              {currentLang.confirmYes}
            </button>
          </div>
        </div>
      )}
    </form>
  );
};

export default FormComponent;




