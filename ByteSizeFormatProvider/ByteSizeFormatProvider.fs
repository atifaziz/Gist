open System

type ByteSizeFormatProvider() =

    let formatSpecifier = "SZ"
    let kiloByte = 1024m
    let megaByte = kiloByte * 1024m
    let gigaByte = megaByte * 1024m

    let rec getPrecisionFormat precision =
        if String.IsNullOrEmpty(precision) then getPrecisionFormat "2"
        else match precision with
             | "0" -> "N0"
             | "1" -> "N1"
             | "2" -> "N2"
             | "3" -> "N3"
             | "4" -> "N4"
             | _ -> "N" + precision

    let defaultFormat format formatProvider (arg : obj) =
        match arg with
        | :? IFormattable as formattable -> formattable.ToString(format, formatProvider)
        | _ -> arg.ToString()

    interface IFormatProvider with
        member this.GetFormat(formatType) =
            if formatType = typeof<ICustomFormatter> then this :> obj else null

    interface ICustomFormatter with
        member this.Format(format, arg, formatProvider) =
            if (format = null
                || not (format.StartsWith(formatSpecifier, StringComparison.Ordinal))
                || arg :? string) then
                arg |> defaultFormat format formatProvider
            else
                let size = try  Some(Convert.ToDecimal(arg, formatProvider))
                           with | :? InvalidCastException -> None
                match size with
                | None -> arg |> defaultFormat format formatProvider
                | Some(size) ->
                    let (size, suffix, ignorePrecision) =
                        if      (size > gigaByte) then (size / gigaByte, "GB", false)
                        else if (size > megaByte) then (size / megaByte, "MB", false)
                        else if (size > kiloByte) then (size / kiloByte, "KB", false)
                        else if (size = 1m      ) then (size, " byte", true)
                        else                           (size, " bytes", true)
                    let precision = if ignorePrecision then "0" else format.Substring(formatSpecifier.Length)
                    size.ToString(getPrecisionFormat precision, formatProvider) + suffix
