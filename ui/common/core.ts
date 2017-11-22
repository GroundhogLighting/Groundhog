export interface Response {
    success: boolean,
    error?: string,
    object?: any
}

export interface Range {
    max: number,
    has_max: boolean,
    min: number,
    has_min: boolean
}
