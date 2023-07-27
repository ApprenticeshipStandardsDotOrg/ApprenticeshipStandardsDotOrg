import * as EventEmitter from 'eventemitter3';
import i18next from 'i18next';

declare type TypedArray =
  | Uint8Array
  | Uint16Array
  | Uint32Array
  | Uint8ClampedArray
  | Int8Array
  | Int16Array
  | Int32Array;
declare type Optional<T> = T | undefined | null;
declare type Or<A, B, C = B, D = C, E = D, F = E> = A | B | C | D | E | F;

interface Class<T> {
  readonly prototype: T;
  new (...args: any[]): T;
}

type PromisifyFunction<F> = F extends (...args: infer P) => infer R
  ? (...args: P) => Promise<R extends Promise<infer P> ? P : R>
  : F;

type PromisifyObject<
  T,
  Exc extends keyof T = never,
  Skip extends keyof T = never
> = {
  [K in Exclude<Exclude<keyof T, Exc>, Skip>]: PromisifyFunction<T[K]>;
} & { [EK in Exclude<Skip, Exc>]: T[EK] };

type PromisifyClass<
  T,
  Exc extends keyof T = never,
  Skip extends keyof T = never
> = Class<PromisifyObject<T, Exc, Skip>>;

declare module __internal__ {
  export interface DevicePoint {
    x: number;
    y: number;
  }

  class DeviceRect {
    bottom: number;
    left: number;
    right: number;
    top: number;
  }

  export interface PDFPoint {
    x: number;
    y: number;
  }

  export interface PDFRect {
    bottom: number;
    left: number;
    right: number;
    top: number;
  }

  class FontMap {
    glyphs: Array<Glyphs>;
    nameMatches: Array<RegExp | String>;
  }

  class Glyphs {
    bold: number;
    flags: number;
    isBrotli: boolean;
    url: string;
  }

  class PageRange {
    end: number;
    filter: number;
    start: number;
  }

  class Unit {
    convertAreaTo(value: number, targetUnit: Unit): number;
    convertTo(value: number, targetUnit: Unit): number;
  }

  class Action {
    getSubAction(index: number): Action;
    getSubActionCount(): number;
    getType(): string;
    insertSubAction(index: number, action: Action): Promise<object>;
    removeAllSubActions(): Promise<void>;
    removeSubAction(index: number): Promise<void>;
    setSubAction(index: number, action: Action): Promise<object>;
  }

  class GoToAction extends Action {
    getDestination(): object;
    setDestination(destination: {
      zoomMode: string;
      zoomFactor: number;
      pageIndex: string;
      left: string;
      top: string;
      right: string;
      bottom: string;
    }): Promise<object>;
    getSubAction(index: number): Action;
    getSubActionCount(): number;
    getType(): string;
    insertSubAction(index: number, action: Action): Promise<object>;
    removeAllSubActions(): Promise<void>;
    removeSubAction(index: number): Promise<void>;
    setSubAction(index: number, action: Action): Promise<object>;
  }

  class HideAction extends Action {
    getFieldNames(): string[];
    getHideState(): boolean;
    setFieldNames(fieldNames: string[]): Promise<object>;
    setHideState(hideState: boolean): Promise<object>;
    getSubAction(index: number): Action;
    getSubActionCount(): number;
    getType(): string;
    insertSubAction(index: number, action: Action): Promise<object>;
    removeAllSubActions(): Promise<void>;
    removeSubAction(index: number): Promise<void>;
    setSubAction(index: number, action: Action): Promise<object>;
  }

  class JavaScriptAction extends Action {
    getScript(): string;
    setScript(script: string): Promise<object>;
    getSubAction(index: number): Action;
    getSubActionCount(): number;
    getType(): string;
    insertSubAction(index: number, action: Action): Promise<object>;
    removeAllSubActions(): Promise<void>;
    removeSubAction(index: number): Promise<void>;
    setSubAction(index: number, action: Action): Promise<object>;
  }

  class ResetFormAction extends Action {
    getFieldNames(): string[];
    getFlags(): boolean;
    setFieldNames(fieldNames: string[]): Promise<Action>;
    setFlags(flags: 0 | 1): Promise<Action>;
    getSubAction(index: number): Action;
    getSubActionCount(): number;
    getType(): string;
    insertSubAction(index: number, action: Action): Promise<object>;
    removeAllSubActions(): Promise<void>;
    removeSubAction(index: number): Promise<void>;
    setSubAction(index: number, action: Action): Promise<object>;
  }

  class URIAction extends Action {
    getURI(): string;
    setURI(uri: string): Promise<Action>;
    getSubAction(index: number): Action;
    getSubActionCount(): number;
    getType(): string;
    insertSubAction(index: number, action: Action): Promise<object>;
    removeAllSubActions(): Promise<void>;
    removeSubAction(index: number): Promise<void>;
    setSubAction(index: number, action: Action): Promise<object>;
  }

  enum Annot_Flags {
    invisible,
    hidden,
    print,
    noZoom,
    noRotate,
    noView,
    readOnly,
    locked,
    toggleNoView,
    lockedContents,
  }

  enum Annot_Type {
    unKnownType,
    text,
    link,
    freeText,
    line,
    square,
    circle,
    polygon,
    polyline,
    highlight,
    underline,
    squiggly,
    strikeOut,
    stamp,
    caret,
    ink,
    psInk,
    fileAttachment,
    widget,
    screen,
    popup,
    redact,
  }

  enum Annot_Unit_Type {
    inch,
    custom,
    mi,
    pt,
    ft,
    yd,
    km,
    m,
    cm,
    mm,
    pica,
  }

  enum MARKUP_ANNOTATION_STATE {
    MARKED,
    UNMARKED,
    ACCEPTED,
    REJECTED,
    CANCELLED,
    COMPLETED,
    DEFERRED,
    FUTURE,
    NONE,
  }

  export interface IAnnotationSummary {
    color: string;
    contents: string;
    customEntries: Record<string, any>;
    dashes: string;
    dashPhase: number;
    date: string;
    flags: string;
    indensity: number;
    name: string;
    objectNumber: number;
    page: number;
    rect: string;
    style: string;
    type: Annot_Type;
    width: number;
  }

  export interface ICaretAnnotationSummary extends IMarkupAnnotationSummary {
    fringe: string;
  }

  export interface ICircleAnnotationSummary extends IMarkupAnnotationSummary {
    fringe: string;
    interiorColor: string;
  }

  export interface IFileAttachmentAnnotationSummary
    extends IMarkupAnnotationSummary {}

  export interface IFreeTextAnnotationSummary extends IMarkupAnnotationSummary {
    defaultappearance: string;
    fontColor: string;
    interiorColor: string;
  }

  export interface IFreeTextCalloutAnnotationSummary
    extends IFreeTextAnnotationSummary {
    callout: string;
    fringe: string;
    head: string;
  }

  export interface IFreeTextTextBoxAnnotationSummary
    extends IFreeTextAnnotationSummary {}

  export interface IFreeTextTypewriterAnnotationSummary
    extends IFreeTextAnnotationSummary {}

  export interface IHighlightAnnotationSummary
    extends ITextMarkupAnnotationSummary {}

  export interface IInkAnnotationSummary extends ITextMarkupAnnotationSummary {
    inkList: string;
  }

  export interface ILineAnnotationSummary extends IMarkupAnnotationSummary {
    caption: string;
    end: string;
    head: string;
    leaderExtend: number;
    leaderLength: number;
    start: string;
    tail: string;
  }

  export interface ILinkAnnotationSummary extends IAnnotationSummary {}

  export interface IMarkupAnnotationSummary extends IAnnotationSummary {
    creationdate: string;
    inreplyto: string;
    intent: string;
    opacity: number;
    popup: IPopupAnnotationSummary;
    replyType: string;
    rotation: number;
    subject: string;
    title: string;
  }

  export interface INoteAnnotationSummary extends IMarkupAnnotationSummary {
    statemodel: string;
  }

  export interface IPolygonAnnotationSummary extends IMarkupAnnotationSummary {
    interiorColor: string;
    vertices: string;
  }

  export interface IPolylineAnnotationSummary extends IMarkupAnnotationSummary {
    head: string;
    interiorColor: string;
    tail: string;
    vertices: string;
  }

  export interface IPopupAnnotationSummary {
    flags: string;
    name: string;
    page: number;
    rect: string;
    type: string;
  }

  export interface IRedactAnnotationSummary extends IMarkupAnnotationSummary {
    coords: string;
    defaultappearance: string;
    fontColor: string;
    interiorColor: string;
    justification: number;
    overlayText: string;
  }

  export interface ISquareAnnotationSummary extends IMarkupAnnotationSummary {
    fringe: string;
    interiorColor: string;
  }

  export interface ISquigglyAnnotationSummary
    extends ITextMarkupAnnotationSummary {}

  export interface IStrikeoutAnnotationSummary
    extends ITextMarkupAnnotationSummary {}

  export interface ITextMarkupAnnotationSummary
    extends IMarkupAnnotationSummary {
    coords: string;
  }

  export interface IUnderlineAnnotationSummary
    extends ITextMarkupAnnotationSummary {}

  class Annot {
    exportToJSON(): object;
    getBorderColor(): number;
    getBorderInfo(): {
      cloudIntensity: number;
      dashPhase: number;
      dashes: number[];
      style: number;
      width: number;
    };
    getContent(): string;
    getDictionaryEntry(key: string): Promise<string>;
    getFlags(): number;
    getModifiedDateTime(): Date | null;
    getObjectNumber(): number;
    getPage(): PDFPage;
    getRect(): PDFRect;
    getTitle(): string;
    getType(): string;
    getUniqueID(): string;
    isEmpty(): boolean;
    isMarkup(): boolean;
    setBorderColor(
      borderColor: number | [string, number, number, number] | string
    ): Promise<boolean>;
    setBorderInfo(borderInfo: {
      cloudIntensity?: number;
      dashPhase?: number;
      dashes?: number[];
      style: Border_Style;
      width: number;
    }): Promise<void>;
    setContent(content: string): Promise<Annot[] | Annot>;
    setDictionaryEntry(key: string, value: string): Promise<boolean>;
    setFlags(flag: number): Promise<boolean>;
    setModifiedDateTime(date: Date | number): Promise<boolean>;
    setRect(rect: PDFRect): Promise<boolean>;
  }

  class AnnotFlag {
    check(flag: number): boolean;
    checkHidden(): boolean;
    checkInvisible(): boolean;
    checkLocked(): boolean;
    checkLockedContents(): boolean;
    checkNoRotate(): boolean;
    checkNoView(): boolean;
    checkNoZoom(): boolean;
    checkPrint(): boolean;
    checkReadOnly(): boolean;
    checkToggleNoView(): boolean;
    getValue(): number;
    or(flag: number): AnnotFlag;
  }

  class Caret extends Markup {
    exportToJSON(): object;
    getInnerRect(): PDFRect;
    moveRectByCharIndex(charIndex: number): Promise<boolean>;
    addMarkedState(stateName: string): Promise<Note>;
    addReply(content: string): Promise<Note>;
    addReviewState(stateName: string): Promise<Note>;
    addRichText(
      datas: Array<{
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    getCreateDateTime(): Date;
    getGroupElements(): Annot[];
    getGroupHeader(): Markup;
    getIntent(): string;
    getMarkedState(index: number): Note;
    getMarkedStateCount(): number;
    getMarkedStates(): Note[];
    getOpacity(): number;
    getPopup(): Annot;
    getReplies(): Note[];
    getReply(index: number): Note;
    getReplyCount(): number;
    getReviewState(index: number): Note;
    getReviewStateCount(): number;
    getReviewStates(): Note[];
    getRichText(): Promise<Array<any>>;
    getSubject(): string;
    getTitle(): string;
    insertRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    isGrouped(): boolean;
    isGroupHeader(): Markup[];
    removeAllStateAnnots(): Promise<boolean>;
    removeRichText(indexes: number[]): void;
    setContent(content: string): Promise<Annot[]>;
    setCreateDateTime(date: number): Promise<Annot[]>;
    setIntent(intent: string): Promise<Annot[]>;
    setOpacity(opacity: number): Promise<Annot[] | boolean>;
    setRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    setSubject(subject: string): Promise<Annot[]>;
    setTitle(title: string): Promise<Annot[]>;
    getBorderColor(): number;
    getBorderInfo(): {
      cloudIntensity: number;
      dashPhase: number;
      dashes: number[];
      style: number;
      width: number;
    };
    getContent(): string;
    getDictionaryEntry(key: string): Promise<string>;
    getFlags(): number;
    getModifiedDateTime(): Date | null;
    getObjectNumber(): number;
    getPage(): PDFPage;
    getRect(): PDFRect;
    getType(): string;
    getUniqueID(): string;
    isEmpty(): boolean;
    isMarkup(): boolean;
    setBorderColor(
      borderColor: number | [string, number, number, number] | string
    ): Promise<boolean>;
    setBorderInfo(borderInfo: {
      cloudIntensity?: number;
      dashPhase?: number;
      dashes?: number[];
      style: Border_Style;
      width: number;
    }): Promise<void>;
    setDictionaryEntry(key: string, value: string): Promise<boolean>;
    setFlags(flag: number): Promise<boolean>;
    setModifiedDateTime(date: Date | number): Promise<boolean>;
    setRect(rect: PDFRect): Promise<boolean>;
  }

  class Circle extends Markup {
    exportToJSON(): object;
    getFillColor(): number;
    getInnerRect(): PDFRect;
    getMeasureConversionFactor(): number;
    getMeasureRatio(): string;
    getMeasureUnit(): string;
    setFillColor(
      fillColor: number | ['T'] | [string, number, number, number] | string
    ): Promise<boolean>;
    setMeasureConversionFactor(factor: number): Promise<void>;
    setMeasureRatio(measurementRatio: {
      userSpaceValue: number;
      userSpaceUnit: string;
      realValue: string;
      realUnit: string;
    }): void;
    setMeasureUnit(unit: string): Promise<void>;
    addMarkedState(stateName: string): Promise<Note>;
    addReply(content: string): Promise<Note>;
    addReviewState(stateName: string): Promise<Note>;
    addRichText(
      datas: Array<{
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    getCreateDateTime(): Date;
    getGroupElements(): Annot[];
    getGroupHeader(): Markup;
    getIntent(): string;
    getMarkedState(index: number): Note;
    getMarkedStateCount(): number;
    getMarkedStates(): Note[];
    getOpacity(): number;
    getPopup(): Annot;
    getReplies(): Note[];
    getReply(index: number): Note;
    getReplyCount(): number;
    getReviewState(index: number): Note;
    getReviewStateCount(): number;
    getReviewStates(): Note[];
    getRichText(): Promise<Array<any>>;
    getSubject(): string;
    getTitle(): string;
    insertRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    isGrouped(): boolean;
    isGroupHeader(): Markup[];
    removeAllStateAnnots(): Promise<boolean>;
    removeRichText(indexes: number[]): void;
    setContent(content: string): Promise<Annot[]>;
    setCreateDateTime(date: number): Promise<Annot[]>;
    setIntent(intent: string): Promise<Annot[]>;
    setOpacity(opacity: number): Promise<Annot[] | boolean>;
    setRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    setSubject(subject: string): Promise<Annot[]>;
    setTitle(title: string): Promise<Annot[]>;
    getBorderColor(): number;
    getBorderInfo(): {
      cloudIntensity: number;
      dashPhase: number;
      dashes: number[];
      style: number;
      width: number;
    };
    getContent(): string;
    getDictionaryEntry(key: string): Promise<string>;
    getFlags(): number;
    getModifiedDateTime(): Date | null;
    getObjectNumber(): number;
    getPage(): PDFPage;
    getRect(): PDFRect;
    getType(): string;
    getUniqueID(): string;
    isEmpty(): boolean;
    isMarkup(): boolean;
    setBorderColor(
      borderColor: number | [string, number, number, number] | string
    ): Promise<boolean>;
    setBorderInfo(borderInfo: {
      cloudIntensity?: number;
      dashPhase?: number;
      dashes?: number[];
      style: Border_Style;
      width: number;
    }): Promise<void>;
    setDictionaryEntry(key: string, value: string): Promise<boolean>;
    setFlags(flag: number): Promise<boolean>;
    setModifiedDateTime(date: Date | number): Promise<boolean>;
    setRect(rect: PDFRect): Promise<boolean>;
  }

  class FileAttachment extends Markup {
    exportToJSON(): object;
    getIconName(): string;
    setIconName(iconName: string): Promise<void>;
    addMarkedState(stateName: string): Promise<Note>;
    addReply(content: string): Promise<Note>;
    addReviewState(stateName: string): Promise<Note>;
    addRichText(
      datas: Array<{
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    getCreateDateTime(): Date;
    getGroupElements(): Annot[];
    getGroupHeader(): Markup;
    getIntent(): string;
    getMarkedState(index: number): Note;
    getMarkedStateCount(): number;
    getMarkedStates(): Note[];
    getOpacity(): number;
    getPopup(): Annot;
    getReplies(): Note[];
    getReply(index: number): Note;
    getReplyCount(): number;
    getReviewState(index: number): Note;
    getReviewStateCount(): number;
    getReviewStates(): Note[];
    getRichText(): Promise<Array<any>>;
    getSubject(): string;
    getTitle(): string;
    insertRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    isGrouped(): boolean;
    isGroupHeader(): Markup[];
    removeAllStateAnnots(): Promise<boolean>;
    removeRichText(indexes: number[]): void;
    setContent(content: string): Promise<Annot[]>;
    setCreateDateTime(date: number): Promise<Annot[]>;
    setIntent(intent: string): Promise<Annot[]>;
    setOpacity(opacity: number): Promise<Annot[] | boolean>;
    setRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    setSubject(subject: string): Promise<Annot[]>;
    setTitle(title: string): Promise<Annot[]>;
    getBorderColor(): number;
    getBorderInfo(): {
      cloudIntensity: number;
      dashPhase: number;
      dashes: number[];
      style: number;
      width: number;
    };
    getContent(): string;
    getDictionaryEntry(key: string): Promise<string>;
    getFlags(): number;
    getModifiedDateTime(): Date | null;
    getObjectNumber(): number;
    getPage(): PDFPage;
    getRect(): PDFRect;
    getType(): string;
    getUniqueID(): string;
    isEmpty(): boolean;
    isMarkup(): boolean;
    setBorderColor(
      borderColor: number | [string, number, number, number] | string
    ): Promise<boolean>;
    setBorderInfo(borderInfo: {
      cloudIntensity?: number;
      dashPhase?: number;
      dashes?: number[];
      style: Border_Style;
      width: number;
    }): Promise<void>;
    setDictionaryEntry(key: string, value: string): Promise<boolean>;
    setFlags(flag: number): Promise<boolean>;
    setModifiedDateTime(date: Date | number): Promise<boolean>;
    setRect(rect: PDFRect): Promise<boolean>;
  }

  class FreeText extends Markup {
    exportToJSON(): object;
    getAlignment(): number;
    getCalloutLineEndingStyle(): number;
    getCalloutLinePoints(): Array<{ x: number; y: number }>;
    getDefaultAppearance(): object;
    getFillColor(): number;
    getInnerRect(): PDFRect;
    getRotation(): number;
    setAlignment(value: number): void;
    setCalloutLineEndingStyle(endingStyle: number): Promise<void>;
    setCalloutLinePoints(
      calloutLinePoints: Array<{ x: number; y: number }>
    ): Promise<void>;
    setDefaultAppearance(defaultAppearance: {
      textColor: number;
      textSize: number;
      font: {
        name: string;
        styles: number;
        charset: number;
      };
    }): Promise<void>;
    setFillColor(
      fillColor: number | ['T'] | [string, number, number, number] | string
    ): Promise<boolean>;
    setInnerRect(rect: PDFRect): void;
    setRotation(rotation: number): Promise<void>;
    addMarkedState(stateName: string): Promise<Note>;
    addReply(content: string): Promise<Note>;
    addReviewState(stateName: string): Promise<Note>;
    addRichText(
      datas: Array<{
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    getCreateDateTime(): Date;
    getGroupElements(): Annot[];
    getGroupHeader(): Markup;
    getIntent(): string;
    getMarkedState(index: number): Note;
    getMarkedStateCount(): number;
    getMarkedStates(): Note[];
    getOpacity(): number;
    getPopup(): Annot;
    getReplies(): Note[];
    getReply(index: number): Note;
    getReplyCount(): number;
    getReviewState(index: number): Note;
    getReviewStateCount(): number;
    getReviewStates(): Note[];
    getRichText(): Promise<Array<any>>;
    getSubject(): string;
    getTitle(): string;
    insertRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    isGrouped(): boolean;
    isGroupHeader(): Markup[];
    removeAllStateAnnots(): Promise<boolean>;
    removeRichText(indexes: number[]): void;
    setContent(content: string): Promise<Annot[]>;
    setCreateDateTime(date: number): Promise<Annot[]>;
    setIntent(intent: string): Promise<Annot[]>;
    setOpacity(opacity: number): Promise<Annot[] | boolean>;
    setRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    setSubject(subject: string): Promise<Annot[]>;
    setTitle(title: string): Promise<Annot[]>;
    getBorderColor(): number;
    getBorderInfo(): {
      cloudIntensity: number;
      dashPhase: number;
      dashes: number[];
      style: number;
      width: number;
    };
    getContent(): string;
    getDictionaryEntry(key: string): Promise<string>;
    getFlags(): number;
    getModifiedDateTime(): Date | null;
    getObjectNumber(): number;
    getPage(): PDFPage;
    getRect(): PDFRect;
    getType(): string;
    getUniqueID(): string;
    isEmpty(): boolean;
    isMarkup(): boolean;
    setBorderColor(
      borderColor: number | [string, number, number, number] | string
    ): Promise<boolean>;
    setBorderInfo(borderInfo: {
      cloudIntensity?: number;
      dashPhase?: number;
      dashes?: number[];
      style: Border_Style;
      width: number;
    }): Promise<void>;
    setDictionaryEntry(key: string, value: string): Promise<boolean>;
    setFlags(flag: number): Promise<boolean>;
    setModifiedDateTime(date: Date | number): Promise<boolean>;
    setRect(rect: PDFRect): Promise<boolean>;
  }

  class Highlight extends TextMarkup {
    exportToJSON(): Record<string, any>;
    getContinuousText(): string;
    getEndCharIndex(): number;
    getQuadPoints(): Array<Array<{ x: number; y: number }>>;
    getStartCharIndex(): number;
    getText(): string;
    updateQuadPointsByCharIndex(
      startCharIndex: number,
      endCharIndex: number
    ): Promise<boolean>;
    addMarkedState(stateName: string): Promise<Note>;
    addReply(content: string): Promise<Note>;
    addReviewState(stateName: string): Promise<Note>;
    addRichText(
      datas: Array<{
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    getCreateDateTime(): Date;
    getGroupElements(): Annot[];
    getGroupHeader(): Markup;
    getIntent(): string;
    getMarkedState(index: number): Note;
    getMarkedStateCount(): number;
    getMarkedStates(): Note[];
    getOpacity(): number;
    getPopup(): Annot;
    getReplies(): Note[];
    getReply(index: number): Note;
    getReplyCount(): number;
    getReviewState(index: number): Note;
    getReviewStateCount(): number;
    getReviewStates(): Note[];
    getRichText(): Promise<Array<any>>;
    getSubject(): string;
    getTitle(): string;
    insertRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    isGrouped(): boolean;
    isGroupHeader(): Markup[];
    removeAllStateAnnots(): Promise<boolean>;
    removeRichText(indexes: number[]): void;
    setContent(content: string): Promise<Annot[]>;
    setCreateDateTime(date: number): Promise<Annot[]>;
    setIntent(intent: string): Promise<Annot[]>;
    setOpacity(opacity: number): Promise<Annot[] | boolean>;
    setRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    setSubject(subject: string): Promise<Annot[]>;
    setTitle(title: string): Promise<Annot[]>;
    getBorderColor(): number;
    getBorderInfo(): {
      cloudIntensity: number;
      dashPhase: number;
      dashes: number[];
      style: number;
      width: number;
    };
    getContent(): string;
    getDictionaryEntry(key: string): Promise<string>;
    getFlags(): number;
    getModifiedDateTime(): Date | null;
    getObjectNumber(): number;
    getPage(): PDFPage;
    getRect(): PDFRect;
    getType(): string;
    getUniqueID(): string;
    isEmpty(): boolean;
    isMarkup(): boolean;
    setBorderColor(
      borderColor: number | [string, number, number, number] | string
    ): Promise<boolean>;
    setBorderInfo(borderInfo: {
      cloudIntensity?: number;
      dashPhase?: number;
      dashes?: number[];
      style: Border_Style;
      width: number;
    }): Promise<void>;
    setDictionaryEntry(key: string, value: string): Promise<boolean>;
    setFlags(flag: number): Promise<boolean>;
    setModifiedDateTime(date: Date | number): Promise<boolean>;
    setRect(rect: PDFRect): Promise<boolean>;
  }

  class Ink extends Markup {
    exportToJSON(): object;
    getInkList(): Array<{ x: number; y: number; type: number }>;
    setInkList(
      inkList: Array<{ x: number; y: number; type: number }>
    ): Promise<boolean>;
    addMarkedState(stateName: string): Promise<Note>;
    addReply(content: string): Promise<Note>;
    addReviewState(stateName: string): Promise<Note>;
    addRichText(
      datas: Array<{
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    getCreateDateTime(): Date;
    getGroupElements(): Annot[];
    getGroupHeader(): Markup;
    getIntent(): string;
    getMarkedState(index: number): Note;
    getMarkedStateCount(): number;
    getMarkedStates(): Note[];
    getOpacity(): number;
    getPopup(): Annot;
    getReplies(): Note[];
    getReply(index: number): Note;
    getReplyCount(): number;
    getReviewState(index: number): Note;
    getReviewStateCount(): number;
    getReviewStates(): Note[];
    getRichText(): Promise<Array<any>>;
    getSubject(): string;
    getTitle(): string;
    insertRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    isGrouped(): boolean;
    isGroupHeader(): Markup[];
    removeAllStateAnnots(): Promise<boolean>;
    removeRichText(indexes: number[]): void;
    setContent(content: string): Promise<Annot[]>;
    setCreateDateTime(date: number): Promise<Annot[]>;
    setIntent(intent: string): Promise<Annot[]>;
    setOpacity(opacity: number): Promise<Annot[] | boolean>;
    setRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    setSubject(subject: string): Promise<Annot[]>;
    setTitle(title: string): Promise<Annot[]>;
    getBorderColor(): number;
    getBorderInfo(): {
      cloudIntensity: number;
      dashPhase: number;
      dashes: number[];
      style: number;
      width: number;
    };
    getContent(): string;
    getDictionaryEntry(key: string): Promise<string>;
    getFlags(): number;
    getModifiedDateTime(): Date | null;
    getObjectNumber(): number;
    getPage(): PDFPage;
    getRect(): PDFRect;
    getType(): string;
    getUniqueID(): string;
    isEmpty(): boolean;
    isMarkup(): boolean;
    setBorderColor(
      borderColor: number | [string, number, number, number] | string
    ): Promise<boolean>;
    setBorderInfo(borderInfo: {
      cloudIntensity?: number;
      dashPhase?: number;
      dashes?: number[];
      style: Border_Style;
      width: number;
    }): Promise<void>;
    setDictionaryEntry(key: string, value: string): Promise<boolean>;
    setFlags(flag: number): Promise<boolean>;
    setModifiedDateTime(date: Date | number): Promise<boolean>;
    setRect(rect: PDFRect): Promise<boolean>;
  }

  class Line extends Markup {
    enableCaption(enable: boolean): Promise<void>;
    exportToJSON(): object;
    getCaptionOffset(): { x: number; y: number };
    getEndingStyle(): number;
    getEndPoint(): { x: number; y: number };
    getLeaderLineExtend(): number;
    getLeaderLineLength(): number;
    getLeaderLineOffset(): number;
    getLeaderLinePoints(): {
      start: { x: number; y: number };
      end: { x: number; y: number };
    };
    getMeasureRatio(): string;
    getMeasureUnit(): string;
    getStartPoint(): { x: number; y: number };
    getStartStyle(): number;
    getStyleFillColor(): number;
    hasCaption(): boolean;
    setCaptionOffset(x: number, y: number): Promise<void>;
    setEndingStyle(isBeginning: boolean, endingStyle: number): Promise<void>;
    setEndPoint(point: { x: number; y: number }): Promise<void>;
    setLeaderLineExtend(length: number): Promise<void>;
    setLeaderLineLength(length: number): Promise<void>;
    setLeaderLineOffset(offset: number): Promise<void>;
    setMeasureRatio(measurementRatio: {
      userSpaceValue: number;
      userSpaceUnit: string;
      realValue: string;
      realUnit: string;
    }): void;
    setMeasureUnit(unit: string): void;
    setStartPoint(point: { x: number; y: number }): Promise<void>;
    setStyleFillColor(
      styleFillColor: number | ['T'] | [string, number, number, number] | string
    ): Promise<boolean>;
    addMarkedState(stateName: string): Promise<Note>;
    addReply(content: string): Promise<Note>;
    addReviewState(stateName: string): Promise<Note>;
    addRichText(
      datas: Array<{
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    getCreateDateTime(): Date;
    getGroupElements(): Annot[];
    getGroupHeader(): Markup;
    getIntent(): string;
    getMarkedState(index: number): Note;
    getMarkedStateCount(): number;
    getMarkedStates(): Note[];
    getOpacity(): number;
    getPopup(): Annot;
    getReplies(): Note[];
    getReply(index: number): Note;
    getReplyCount(): number;
    getReviewState(index: number): Note;
    getReviewStateCount(): number;
    getReviewStates(): Note[];
    getRichText(): Promise<Array<any>>;
    getSubject(): string;
    getTitle(): string;
    insertRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    isGrouped(): boolean;
    isGroupHeader(): Markup[];
    removeAllStateAnnots(): Promise<boolean>;
    removeRichText(indexes: number[]): void;
    setContent(content: string): Promise<Annot[]>;
    setCreateDateTime(date: number): Promise<Annot[]>;
    setIntent(intent: string): Promise<Annot[]>;
    setOpacity(opacity: number): Promise<Annot[] | boolean>;
    setRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    setSubject(subject: string): Promise<Annot[]>;
    setTitle(title: string): Promise<Annot[]>;
    getBorderColor(): number;
    getBorderInfo(): {
      cloudIntensity: number;
      dashPhase: number;
      dashes: number[];
      style: number;
      width: number;
    };
    getContent(): string;
    getDictionaryEntry(key: string): Promise<string>;
    getFlags(): number;
    getModifiedDateTime(): Date | null;
    getObjectNumber(): number;
    getPage(): PDFPage;
    getRect(): PDFRect;
    getType(): string;
    getUniqueID(): string;
    isEmpty(): boolean;
    isMarkup(): boolean;
    setBorderColor(
      borderColor: number | [string, number, number, number] | string
    ): Promise<boolean>;
    setBorderInfo(borderInfo: {
      cloudIntensity?: number;
      dashPhase?: number;
      dashes?: number[];
      style: Border_Style;
      width: number;
    }): Promise<void>;
    setDictionaryEntry(key: string, value: string): Promise<boolean>;
    setFlags(flag: number): Promise<boolean>;
    setModifiedDateTime(date: Date | number): Promise<boolean>;
    setRect(rect: PDFRect): Promise<boolean>;
  }

  class Link extends Annot {
    getAction(): Action;
    getHighlightingMode(): number;
    removeAction(): Promise<boolean>;
    setAction(action: Action): Promise<boolean>;
    setHighlightingMode(highlightingMode: number): Promise<void>;
    exportToJSON(): object;
    getBorderColor(): number;
    getBorderInfo(): {
      cloudIntensity: number;
      dashPhase: number;
      dashes: number[];
      style: number;
      width: number;
    };
    getContent(): string;
    getDictionaryEntry(key: string): Promise<string>;
    getFlags(): number;
    getModifiedDateTime(): Date | null;
    getObjectNumber(): number;
    getPage(): PDFPage;
    getRect(): PDFRect;
    getTitle(): string;
    getType(): string;
    getUniqueID(): string;
    isEmpty(): boolean;
    isMarkup(): boolean;
    setBorderColor(
      borderColor: number | [string, number, number, number] | string
    ): Promise<boolean>;
    setBorderInfo(borderInfo: {
      cloudIntensity?: number;
      dashPhase?: number;
      dashes?: number[];
      style: Border_Style;
      width: number;
    }): Promise<void>;
    setContent(content: string): Promise<Annot[] | Annot>;
    setDictionaryEntry(key: string, value: string): Promise<boolean>;
    setFlags(flag: number): Promise<boolean>;
    setModifiedDateTime(date: Date | number): Promise<boolean>;
    setRect(rect: PDFRect): Promise<boolean>;
  }

  class Markup extends Annot {
    addMarkedState(stateName: string): Promise<Note>;
    addReply(content: string): Promise<Note>;
    addReviewState(stateName: string): Promise<Note>;
    addRichText(
      datas: Array<{
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    exportToJSON(): object;
    getCreateDateTime(): Date;
    getGroupElements(): Annot[];
    getGroupHeader(): Markup;
    getIntent(): string;
    getMarkedState(index: number): Note;
    getMarkedStateCount(): number;
    getMarkedStates(): Note[];
    getOpacity(): number;
    getPopup(): Annot;
    getReplies(): Note[];
    getReply(index: number): Note;
    getReplyCount(): number;
    getReviewState(index: number): Note;
    getReviewStateCount(): number;
    getReviewStates(): Note[];
    getRichText(): Promise<Array<any>>;
    getSubject(): string;
    getTitle(): string;
    insertRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    isGrouped(): boolean;
    isGroupHeader(): Markup[];
    removeAllStateAnnots(): Promise<boolean>;
    removeRichText(indexes: number[]): void;
    setContent(content: string): Promise<Annot[]>;
    setCreateDateTime(date: number): Promise<Annot[]>;
    setIntent(intent: string): Promise<Annot[]>;
    setOpacity(opacity: number): Promise<Annot[] | boolean>;
    setRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    setSubject(subject: string): Promise<Annot[]>;
    setTitle(title: string): Promise<Annot[]>;
    getBorderColor(): number;
    getBorderInfo(): {
      cloudIntensity: number;
      dashPhase: number;
      dashes: number[];
      style: number;
      width: number;
    };
    getContent(): string;
    getDictionaryEntry(key: string): Promise<string>;
    getFlags(): number;
    getModifiedDateTime(): Date | null;
    getObjectNumber(): number;
    getPage(): PDFPage;
    getRect(): PDFRect;
    getType(): string;
    getUniqueID(): string;
    isEmpty(): boolean;
    isMarkup(): boolean;
    setBorderColor(
      borderColor: number | [string, number, number, number] | string
    ): Promise<boolean>;
    setBorderInfo(borderInfo: {
      cloudIntensity?: number;
      dashPhase?: number;
      dashes?: number[];
      style: Border_Style;
      width: number;
    }): Promise<void>;
    setDictionaryEntry(key: string, value: string): Promise<boolean>;
    setFlags(flag: number): Promise<boolean>;
    setModifiedDateTime(date: Date | number): Promise<boolean>;
    setRect(rect: PDFRect): Promise<boolean>;
  }

  class Note extends Markup {
    exportToJSON(): Record<string, any>;
    getIconName(): string;
    setIconName(iconName: string): Promise<boolean>;
    addMarkedState(stateName: string): Promise<Note>;
    addReply(content: string): Promise<Note>;
    addReviewState(stateName: string): Promise<Note>;
    addRichText(
      datas: Array<{
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    getCreateDateTime(): Date;
    getGroupElements(): Annot[];
    getGroupHeader(): Markup;
    getIntent(): string;
    getMarkedState(index: number): Note;
    getMarkedStateCount(): number;
    getMarkedStates(): Note[];
    getOpacity(): number;
    getPopup(): Annot;
    getReplies(): Note[];
    getReply(index: number): Note;
    getReplyCount(): number;
    getReviewState(index: number): Note;
    getReviewStateCount(): number;
    getReviewStates(): Note[];
    getRichText(): Promise<Array<any>>;
    getSubject(): string;
    getTitle(): string;
    insertRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    isGrouped(): boolean;
    isGroupHeader(): Markup[];
    removeAllStateAnnots(): Promise<boolean>;
    removeRichText(indexes: number[]): void;
    setContent(content: string): Promise<Annot[]>;
    setCreateDateTime(date: number): Promise<Annot[]>;
    setIntent(intent: string): Promise<Annot[]>;
    setOpacity(opacity: number): Promise<Annot[] | boolean>;
    setRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    setSubject(subject: string): Promise<Annot[]>;
    setTitle(title: string): Promise<Annot[]>;
    getBorderColor(): number;
    getBorderInfo(): {
      cloudIntensity: number;
      dashPhase: number;
      dashes: number[];
      style: number;
      width: number;
    };
    getContent(): string;
    getDictionaryEntry(key: string): Promise<string>;
    getFlags(): number;
    getModifiedDateTime(): Date | null;
    getObjectNumber(): number;
    getPage(): PDFPage;
    getRect(): PDFRect;
    getType(): string;
    getUniqueID(): string;
    isEmpty(): boolean;
    isMarkup(): boolean;
    setBorderColor(
      borderColor: number | [string, number, number, number] | string
    ): Promise<boolean>;
    setBorderInfo(borderInfo: {
      cloudIntensity?: number;
      dashPhase?: number;
      dashes?: number[];
      style: Border_Style;
      width: number;
    }): Promise<void>;
    setDictionaryEntry(key: string, value: string): Promise<boolean>;
    setFlags(flag: number): Promise<boolean>;
    setModifiedDateTime(date: Date | number): Promise<boolean>;
    setRect(rect: PDFRect): Promise<boolean>;
  }

  class Polygon extends Markup {
    enableCaption(enable: boolean): Promise<void>;
    exportToJSON(): Record<string, any>;
    getFillColor(): number;
    getMeasureRatio(): string;
    getVertexes(): Array<{ x: number; y: number }>;
    hasCaption(): boolean;
    setFillColor(
      fillColor: number | ['T'] | [string, number, number, number] | string
    ): Promise<boolean>;
    setMeasureRatio(measurementRatio: {
      userSpaceValue: number;
      userSpaceUnit: string;
      realValue: string;
      realUnit: string;
    }): void;
    setVertexes(vertexes: Array<{ x: number; y: number }>): Promise<void>;
    updateVertexes(
      index: number,
      point: { x: number; y: number }
    ): Promise<void>;
    addMarkedState(stateName: string): Promise<Note>;
    addReply(content: string): Promise<Note>;
    addReviewState(stateName: string): Promise<Note>;
    addRichText(
      datas: Array<{
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    getCreateDateTime(): Date;
    getGroupElements(): Annot[];
    getGroupHeader(): Markup;
    getIntent(): string;
    getMarkedState(index: number): Note;
    getMarkedStateCount(): number;
    getMarkedStates(): Note[];
    getOpacity(): number;
    getPopup(): Annot;
    getReplies(): Note[];
    getReply(index: number): Note;
    getReplyCount(): number;
    getReviewState(index: number): Note;
    getReviewStateCount(): number;
    getReviewStates(): Note[];
    getRichText(): Promise<Array<any>>;
    getSubject(): string;
    getTitle(): string;
    insertRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    isGrouped(): boolean;
    isGroupHeader(): Markup[];
    removeAllStateAnnots(): Promise<boolean>;
    removeRichText(indexes: number[]): void;
    setContent(content: string): Promise<Annot[]>;
    setCreateDateTime(date: number): Promise<Annot[]>;
    setIntent(intent: string): Promise<Annot[]>;
    setOpacity(opacity: number): Promise<Annot[] | boolean>;
    setRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    setSubject(subject: string): Promise<Annot[]>;
    setTitle(title: string): Promise<Annot[]>;
    getBorderColor(): number;
    getBorderInfo(): {
      cloudIntensity: number;
      dashPhase: number;
      dashes: number[];
      style: number;
      width: number;
    };
    getContent(): string;
    getDictionaryEntry(key: string): Promise<string>;
    getFlags(): number;
    getModifiedDateTime(): Date | null;
    getObjectNumber(): number;
    getPage(): PDFPage;
    getRect(): PDFRect;
    getType(): string;
    getUniqueID(): string;
    isEmpty(): boolean;
    isMarkup(): boolean;
    setBorderColor(
      borderColor: number | [string, number, number, number] | string
    ): Promise<boolean>;
    setBorderInfo(borderInfo: {
      cloudIntensity?: number;
      dashPhase?: number;
      dashes?: number[];
      style: Border_Style;
      width: number;
    }): Promise<void>;
    setDictionaryEntry(key: string, value: string): Promise<boolean>;
    setFlags(flag: number): Promise<boolean>;
    setModifiedDateTime(date: Date | number): Promise<boolean>;
    setRect(rect: PDFRect): Promise<boolean>;
  }

  class PolyLine extends Markup {
    enableCaption(enable: boolean): Promise<void>;
    exportToJSON(): Record<string, any>;
    getEndingStyle(): number;
    getMeasureRatio(): string;
    getStartStyle(): number;
    getStyleFillColor(): number;
    getVertexes(): Array<{ x: number; y: number }>;
    hasCaption(): boolean;
    setEndingStyle(isBeginning: boolean, endingStyle: number): Promise<void>;
    setMeasureRatio(measurementRatio: {
      userSpaceValue: number;
      userSpaceUnit: string;
      realValue: string;
      realUnit: string;
    }): void;
    setStyleFillColor(
      styleFillColor: number | ['T'] | [string, number, number, number] | string
    ): Promise<boolean>;
    setVertexes(vertexes: Array<{ x: number; y: number }>): Promise<void>;
    updateVertexes(index: number, point: { x: number; y: number }): void;
    addMarkedState(stateName: string): Promise<Note>;
    addReply(content: string): Promise<Note>;
    addReviewState(stateName: string): Promise<Note>;
    addRichText(
      datas: Array<{
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    getCreateDateTime(): Date;
    getGroupElements(): Annot[];
    getGroupHeader(): Markup;
    getIntent(): string;
    getMarkedState(index: number): Note;
    getMarkedStateCount(): number;
    getMarkedStates(): Note[];
    getOpacity(): number;
    getPopup(): Annot;
    getReplies(): Note[];
    getReply(index: number): Note;
    getReplyCount(): number;
    getReviewState(index: number): Note;
    getReviewStateCount(): number;
    getReviewStates(): Note[];
    getRichText(): Promise<Array<any>>;
    getSubject(): string;
    getTitle(): string;
    insertRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    isGrouped(): boolean;
    isGroupHeader(): Markup[];
    removeAllStateAnnots(): Promise<boolean>;
    removeRichText(indexes: number[]): void;
    setContent(content: string): Promise<Annot[]>;
    setCreateDateTime(date: number): Promise<Annot[]>;
    setIntent(intent: string): Promise<Annot[]>;
    setOpacity(opacity: number): Promise<Annot[] | boolean>;
    setRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    setSubject(subject: string): Promise<Annot[]>;
    setTitle(title: string): Promise<Annot[]>;
    getBorderColor(): number;
    getBorderInfo(): {
      cloudIntensity: number;
      dashPhase: number;
      dashes: number[];
      style: number;
      width: number;
    };
    getContent(): string;
    getDictionaryEntry(key: string): Promise<string>;
    getFlags(): number;
    getModifiedDateTime(): Date | null;
    getObjectNumber(): number;
    getPage(): PDFPage;
    getRect(): PDFRect;
    getType(): string;
    getUniqueID(): string;
    isEmpty(): boolean;
    isMarkup(): boolean;
    setBorderColor(
      borderColor: number | [string, number, number, number] | string
    ): Promise<boolean>;
    setBorderInfo(borderInfo: {
      cloudIntensity?: number;
      dashPhase?: number;
      dashes?: number[];
      style: Border_Style;
      width: number;
    }): Promise<void>;
    setDictionaryEntry(key: string, value: string): Promise<boolean>;
    setFlags(flag: number): Promise<boolean>;
    setModifiedDateTime(date: Date | number): Promise<boolean>;
    setRect(rect: PDFRect): Promise<boolean>;
  }

  class Redact extends Markup {
    apply(): Promise<Array<{ pageIndex: number; removedAnnots: number[] }>>;
    getDefaultAppearance(): { textColor: number; textSize: number };
    getFillColor(): number;
    getOverlayText(): string;
    getOverlayTextAlignment(): '0' | '1' | '2';
    getRepeat(): boolean;
    removeOverlayText(): Promise<boolean>;
    setAutoFontSize(isAutoFontSize: boolean): Promise<boolean>;
    setDefaultAppearance(appearance: {
      fontName: string;
      textSize: number;
      textColor: number;
    }): Promise<boolean>;
    setFillColor(fillColor: number): Promise<boolean>;
    setOpacity(opacity: number, onlyForFill?: boolean): Promise<boolean>;
    setOverlayText(overlayText: string): Promise<boolean>;
    setOverlayTextAlignment(alignment: 0 | 1 | 2): Promise<boolean>;
    setRedactApplyFillColor(
      applyFillColor: number | ['T'] | [string, number, number, number] | string
    ): Promise<boolean>;
    setRepeat(isRepeat: boolean): Promise<boolean>;
    addMarkedState(stateName: string): Promise<Note>;
    addReply(content: string): Promise<Note>;
    addReviewState(stateName: string): Promise<Note>;
    addRichText(
      datas: Array<{
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    exportToJSON(): object;
    getCreateDateTime(): Date;
    getGroupElements(): Annot[];
    getGroupHeader(): Markup;
    getIntent(): string;
    getMarkedState(index: number): Note;
    getMarkedStateCount(): number;
    getMarkedStates(): Note[];
    getOpacity(): number;
    getPopup(): Annot;
    getReplies(): Note[];
    getReply(index: number): Note;
    getReplyCount(): number;
    getReviewState(index: number): Note;
    getReviewStateCount(): number;
    getReviewStates(): Note[];
    getRichText(): Promise<Array<any>>;
    getSubject(): string;
    getTitle(): string;
    insertRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    isGrouped(): boolean;
    isGroupHeader(): Markup[];
    removeAllStateAnnots(): Promise<boolean>;
    removeRichText(indexes: number[]): void;
    setContent(content: string): Promise<Annot[]>;
    setCreateDateTime(date: number): Promise<Annot[]>;
    setIntent(intent: string): Promise<Annot[]>;
    setRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    setSubject(subject: string): Promise<Annot[]>;
    setTitle(title: string): Promise<Annot[]>;
    getBorderColor(): number;
    getBorderInfo(): {
      cloudIntensity: number;
      dashPhase: number;
      dashes: number[];
      style: number;
      width: number;
    };
    getContent(): string;
    getDictionaryEntry(key: string): Promise<string>;
    getFlags(): number;
    getModifiedDateTime(): Date | null;
    getObjectNumber(): number;
    getPage(): PDFPage;
    getRect(): PDFRect;
    getType(): string;
    getUniqueID(): string;
    isEmpty(): boolean;
    isMarkup(): boolean;
    setBorderColor(
      borderColor: number | [string, number, number, number] | string
    ): Promise<boolean>;
    setBorderInfo(borderInfo: {
      cloudIntensity?: number;
      dashPhase?: number;
      dashes?: number[];
      style: Border_Style;
      width: number;
    }): Promise<void>;
    setDictionaryEntry(key: string, value: string): Promise<boolean>;
    setFlags(flag: number): Promise<boolean>;
    setModifiedDateTime(date: Date | number): Promise<boolean>;
    setRect(rect: PDFRect): Promise<boolean>;
  }

  class Screen extends Annot {
    getAction(): Action;
    getImage(
      type?: 'canvas' | 'image' | 'buffer'
    ): Promise<ArrayBuffer | HTMLImageElement | HTMLCanvasElement>;
    getOpacity(): number;
    getRotation(): number;
    removeAction(): Promise<boolean>;
    setImage(buffer: ArrayBuffer): Promise<boolean>;
    setOpacity(opacity: number): Promise<Annot[]>;
    setRotation(rotation: 0 | 90 | 180 | 270): void;
    exportToJSON(): object;
    getBorderColor(): number;
    getBorderInfo(): {
      cloudIntensity: number;
      dashPhase: number;
      dashes: number[];
      style: number;
      width: number;
    };
    getContent(): string;
    getDictionaryEntry(key: string): Promise<string>;
    getFlags(): number;
    getModifiedDateTime(): Date | null;
    getObjectNumber(): number;
    getPage(): PDFPage;
    getRect(): PDFRect;
    getTitle(): string;
    getType(): string;
    getUniqueID(): string;
    isEmpty(): boolean;
    isMarkup(): boolean;
    setBorderColor(
      borderColor: number | [string, number, number, number] | string
    ): Promise<boolean>;
    setBorderInfo(borderInfo: {
      cloudIntensity?: number;
      dashPhase?: number;
      dashes?: number[];
      style: Border_Style;
      width: number;
    }): Promise<void>;
    setContent(content: string): Promise<Annot[] | Annot>;
    setDictionaryEntry(key: string, value: string): Promise<boolean>;
    setFlags(flag: number): Promise<boolean>;
    setModifiedDateTime(date: Date | number): Promise<boolean>;
    setRect(rect: PDFRect): Promise<boolean>;
  }

  class Sound extends Markup {
    getIconName(): string;
    addMarkedState(stateName: string): Promise<Note>;
    addReply(content: string): Promise<Note>;
    addReviewState(stateName: string): Promise<Note>;
    addRichText(
      datas: Array<{
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    exportToJSON(): object;
    getCreateDateTime(): Date;
    getGroupElements(): Annot[];
    getGroupHeader(): Markup;
    getIntent(): string;
    getMarkedState(index: number): Note;
    getMarkedStateCount(): number;
    getMarkedStates(): Note[];
    getOpacity(): number;
    getPopup(): Annot;
    getReplies(): Note[];
    getReply(index: number): Note;
    getReplyCount(): number;
    getReviewState(index: number): Note;
    getReviewStateCount(): number;
    getReviewStates(): Note[];
    getRichText(): Promise<Array<any>>;
    getSubject(): string;
    getTitle(): string;
    insertRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    isGrouped(): boolean;
    isGroupHeader(): Markup[];
    removeAllStateAnnots(): Promise<boolean>;
    removeRichText(indexes: number[]): void;
    setContent(content: string): Promise<Annot[]>;
    setCreateDateTime(date: number): Promise<Annot[]>;
    setIntent(intent: string): Promise<Annot[]>;
    setOpacity(opacity: number): Promise<Annot[] | boolean>;
    setRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    setSubject(subject: string): Promise<Annot[]>;
    setTitle(title: string): Promise<Annot[]>;
    getBorderColor(): number;
    getBorderInfo(): {
      cloudIntensity: number;
      dashPhase: number;
      dashes: number[];
      style: number;
      width: number;
    };
    getContent(): string;
    getDictionaryEntry(key: string): Promise<string>;
    getFlags(): number;
    getModifiedDateTime(): Date | null;
    getObjectNumber(): number;
    getPage(): PDFPage;
    getRect(): PDFRect;
    getType(): string;
    getUniqueID(): string;
    isEmpty(): boolean;
    isMarkup(): boolean;
    setBorderColor(
      borderColor: number | [string, number, number, number] | string
    ): Promise<boolean>;
    setBorderInfo(borderInfo: {
      cloudIntensity?: number;
      dashPhase?: number;
      dashes?: number[];
      style: Border_Style;
      width: number;
    }): Promise<void>;
    setDictionaryEntry(key: string, value: string): Promise<boolean>;
    setFlags(flag: number): Promise<boolean>;
    setModifiedDateTime(date: Date | number): Promise<boolean>;
    setRect(rect: PDFRect): Promise<boolean>;
  }

  class Square extends Markup {
    exportToJSON(): Record<string, any>;
    getFillColor(): number;
    getInnerRect(): PDFRect;
    getMeasureConversionFactor(): number;
    getMeasureRatio(): string;
    getMeasureUnit(): string;
    setFillColor(
      fillColor: number | ['T'] | [string, number, number, number] | string
    ): Promise<boolean>;
    setMeasureConversionFactor(factor: number): void;
    setMeasureRatio(measurementRatio: {
      userSpaceValue: number;
      userSpaceUnit: string;
      realValue: string;
      realUnit: string;
    }): void;
    setMeasureUnit(unit: string): void;
    addMarkedState(stateName: string): Promise<Note>;
    addReply(content: string): Promise<Note>;
    addReviewState(stateName: string): Promise<Note>;
    addRichText(
      datas: Array<{
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    getCreateDateTime(): Date;
    getGroupElements(): Annot[];
    getGroupHeader(): Markup;
    getIntent(): string;
    getMarkedState(index: number): Note;
    getMarkedStateCount(): number;
    getMarkedStates(): Note[];
    getOpacity(): number;
    getPopup(): Annot;
    getReplies(): Note[];
    getReply(index: number): Note;
    getReplyCount(): number;
    getReviewState(index: number): Note;
    getReviewStateCount(): number;
    getReviewStates(): Note[];
    getRichText(): Promise<Array<any>>;
    getSubject(): string;
    getTitle(): string;
    insertRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    isGrouped(): boolean;
    isGroupHeader(): Markup[];
    removeAllStateAnnots(): Promise<boolean>;
    removeRichText(indexes: number[]): void;
    setContent(content: string): Promise<Annot[]>;
    setCreateDateTime(date: number): Promise<Annot[]>;
    setIntent(intent: string): Promise<Annot[]>;
    setOpacity(opacity: number): Promise<Annot[] | boolean>;
    setRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    setSubject(subject: string): Promise<Annot[]>;
    setTitle(title: string): Promise<Annot[]>;
    getBorderColor(): number;
    getBorderInfo(): {
      cloudIntensity: number;
      dashPhase: number;
      dashes: number[];
      style: number;
      width: number;
    };
    getContent(): string;
    getDictionaryEntry(key: string): Promise<string>;
    getFlags(): number;
    getModifiedDateTime(): Date | null;
    getObjectNumber(): number;
    getPage(): PDFPage;
    getRect(): PDFRect;
    getType(): string;
    getUniqueID(): string;
    isEmpty(): boolean;
    isMarkup(): boolean;
    setBorderColor(
      borderColor: number | [string, number, number, number] | string
    ): Promise<boolean>;
    setBorderInfo(borderInfo: {
      cloudIntensity?: number;
      dashPhase?: number;
      dashes?: number[];
      style: Border_Style;
      width: number;
    }): Promise<void>;
    setDictionaryEntry(key: string, value: string): Promise<boolean>;
    setFlags(flag: number): Promise<boolean>;
    setModifiedDateTime(date: Date | number): Promise<boolean>;
    setRect(rect: PDFRect): Promise<boolean>;
  }

  class Squiggly extends TextMarkup {
    exportToJSON(): Record<string, any>;
    getContinuousText(): string;
    getEndCharIndex(): number;
    getQuadPoints(): Array<Array<{ x: number; y: number }>>;
    getStartCharIndex(): number;
    getText(): string;
    updateQuadPointsByCharIndex(
      startCharIndex: number,
      endCharIndex: number
    ): Promise<boolean>;
    addMarkedState(stateName: string): Promise<Note>;
    addReply(content: string): Promise<Note>;
    addReviewState(stateName: string): Promise<Note>;
    addRichText(
      datas: Array<{
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    getCreateDateTime(): Date;
    getGroupElements(): Annot[];
    getGroupHeader(): Markup;
    getIntent(): string;
    getMarkedState(index: number): Note;
    getMarkedStateCount(): number;
    getMarkedStates(): Note[];
    getOpacity(): number;
    getPopup(): Annot;
    getReplies(): Note[];
    getReply(index: number): Note;
    getReplyCount(): number;
    getReviewState(index: number): Note;
    getReviewStateCount(): number;
    getReviewStates(): Note[];
    getRichText(): Promise<Array<any>>;
    getSubject(): string;
    getTitle(): string;
    insertRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    isGrouped(): boolean;
    isGroupHeader(): Markup[];
    removeAllStateAnnots(): Promise<boolean>;
    removeRichText(indexes: number[]): void;
    setContent(content: string): Promise<Annot[]>;
    setCreateDateTime(date: number): Promise<Annot[]>;
    setIntent(intent: string): Promise<Annot[]>;
    setOpacity(opacity: number): Promise<Annot[] | boolean>;
    setRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    setSubject(subject: string): Promise<Annot[]>;
    setTitle(title: string): Promise<Annot[]>;
    getBorderColor(): number;
    getBorderInfo(): {
      cloudIntensity: number;
      dashPhase: number;
      dashes: number[];
      style: number;
      width: number;
    };
    getContent(): string;
    getDictionaryEntry(key: string): Promise<string>;
    getFlags(): number;
    getModifiedDateTime(): Date | null;
    getObjectNumber(): number;
    getPage(): PDFPage;
    getRect(): PDFRect;
    getType(): string;
    getUniqueID(): string;
    isEmpty(): boolean;
    isMarkup(): boolean;
    setBorderColor(
      borderColor: number | [string, number, number, number] | string
    ): Promise<boolean>;
    setBorderInfo(borderInfo: {
      cloudIntensity?: number;
      dashPhase?: number;
      dashes?: number[];
      style: Border_Style;
      width: number;
    }): Promise<void>;
    setDictionaryEntry(key: string, value: string): Promise<boolean>;
    setFlags(flag: number): Promise<boolean>;
    setModifiedDateTime(date: Date | number): Promise<boolean>;
    setRect(rect: PDFRect): Promise<boolean>;
  }

  class Stamp extends Markup {
    exportToJSON(): Record<string, any>;
    getImage(
      type?: 'canvas' | 'image' | 'buffer'
    ): Promise<HTMLCanvasElement | HTMLImageElement | ArrayBuffer>;
    getRotation(): number;
    setRotation(rotation: number): void;
    addMarkedState(stateName: string): Promise<Note>;
    addReply(content: string): Promise<Note>;
    addReviewState(stateName: string): Promise<Note>;
    addRichText(
      datas: Array<{
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    getCreateDateTime(): Date;
    getGroupElements(): Annot[];
    getGroupHeader(): Markup;
    getIntent(): string;
    getMarkedState(index: number): Note;
    getMarkedStateCount(): number;
    getMarkedStates(): Note[];
    getOpacity(): number;
    getPopup(): Annot;
    getReplies(): Note[];
    getReply(index: number): Note;
    getReplyCount(): number;
    getReviewState(index: number): Note;
    getReviewStateCount(): number;
    getReviewStates(): Note[];
    getRichText(): Promise<Array<any>>;
    getSubject(): string;
    getTitle(): string;
    insertRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    isGrouped(): boolean;
    isGroupHeader(): Markup[];
    removeAllStateAnnots(): Promise<boolean>;
    removeRichText(indexes: number[]): void;
    setContent(content: string): Promise<Annot[]>;
    setCreateDateTime(date: number): Promise<Annot[]>;
    setIntent(intent: string): Promise<Annot[]>;
    setOpacity(opacity: number): Promise<Annot[] | boolean>;
    setRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    setSubject(subject: string): Promise<Annot[]>;
    setTitle(title: string): Promise<Annot[]>;
    getBorderColor(): number;
    getBorderInfo(): {
      cloudIntensity: number;
      dashPhase: number;
      dashes: number[];
      style: number;
      width: number;
    };
    getContent(): string;
    getDictionaryEntry(key: string): Promise<string>;
    getFlags(): number;
    getModifiedDateTime(): Date | null;
    getObjectNumber(): number;
    getPage(): PDFPage;
    getRect(): PDFRect;
    getType(): string;
    getUniqueID(): string;
    isEmpty(): boolean;
    isMarkup(): boolean;
    setBorderColor(
      borderColor: number | [string, number, number, number] | string
    ): Promise<boolean>;
    setBorderInfo(borderInfo: {
      cloudIntensity?: number;
      dashPhase?: number;
      dashes?: number[];
      style: Border_Style;
      width: number;
    }): Promise<void>;
    setDictionaryEntry(key: string, value: string): Promise<boolean>;
    setFlags(flag: number): Promise<boolean>;
    setModifiedDateTime(date: Date | number): Promise<boolean>;
    setRect(rect: PDFRect): Promise<boolean>;
  }

  class StrikeOut extends TextMarkup {
    exportToJSON(): Record<string, any>;
    getContinuousText(): string;
    getEndCharIndex(): number;
    getQuadPoints(): Array<Array<{ x: number; y: number }>>;
    getStartCharIndex(): number;
    getText(): string;
    updateQuadPointsByCharIndex(
      startCharIndex: number,
      endCharIndex: number
    ): Promise<boolean>;
    addMarkedState(stateName: string): Promise<Note>;
    addReply(content: string): Promise<Note>;
    addReviewState(stateName: string): Promise<Note>;
    addRichText(
      datas: Array<{
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    getCreateDateTime(): Date;
    getGroupElements(): Annot[];
    getGroupHeader(): Markup;
    getIntent(): string;
    getMarkedState(index: number): Note;
    getMarkedStateCount(): number;
    getMarkedStates(): Note[];
    getOpacity(): number;
    getPopup(): Annot;
    getReplies(): Note[];
    getReply(index: number): Note;
    getReplyCount(): number;
    getReviewState(index: number): Note;
    getReviewStateCount(): number;
    getReviewStates(): Note[];
    getRichText(): Promise<Array<any>>;
    getSubject(): string;
    getTitle(): string;
    insertRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    isGrouped(): boolean;
    isGroupHeader(): Markup[];
    removeAllStateAnnots(): Promise<boolean>;
    removeRichText(indexes: number[]): void;
    setContent(content: string): Promise<Annot[]>;
    setCreateDateTime(date: number): Promise<Annot[]>;
    setIntent(intent: string): Promise<Annot[]>;
    setOpacity(opacity: number): Promise<Annot[] | boolean>;
    setRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    setSubject(subject: string): Promise<Annot[]>;
    setTitle(title: string): Promise<Annot[]>;
    getBorderColor(): number;
    getBorderInfo(): {
      cloudIntensity: number;
      dashPhase: number;
      dashes: number[];
      style: number;
      width: number;
    };
    getContent(): string;
    getDictionaryEntry(key: string): Promise<string>;
    getFlags(): number;
    getModifiedDateTime(): Date | null;
    getObjectNumber(): number;
    getPage(): PDFPage;
    getRect(): PDFRect;
    getType(): string;
    getUniqueID(): string;
    isEmpty(): boolean;
    isMarkup(): boolean;
    setBorderColor(
      borderColor: number | [string, number, number, number] | string
    ): Promise<boolean>;
    setBorderInfo(borderInfo: {
      cloudIntensity?: number;
      dashPhase?: number;
      dashes?: number[];
      style: Border_Style;
      width: number;
    }): Promise<void>;
    setDictionaryEntry(key: string, value: string): Promise<boolean>;
    setFlags(flag: number): Promise<boolean>;
    setModifiedDateTime(date: Date | number): Promise<boolean>;
    setRect(rect: PDFRect): Promise<boolean>;
  }

  class TextMarkup extends Markup {
    constructor(info: object, page: PDFPage);

    exportToJSON(): Record<string, any>;
    getContinuousText(): string;
    getEndCharIndex(): number;
    getQuadPoints(): Array<Array<{ x: number; y: number }>>;
    getStartCharIndex(): number;
    getText(): string;
    updateQuadPointsByCharIndex(
      startCharIndex: number,
      endCharIndex: number
    ): Promise<boolean>;
    addMarkedState(stateName: string): Promise<Note>;
    addReply(content: string): Promise<Note>;
    addReviewState(stateName: string): Promise<Note>;
    addRichText(
      datas: Array<{
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    getCreateDateTime(): Date;
    getGroupElements(): Annot[];
    getGroupHeader(): Markup;
    getIntent(): string;
    getMarkedState(index: number): Note;
    getMarkedStateCount(): number;
    getMarkedStates(): Note[];
    getOpacity(): number;
    getPopup(): Annot;
    getReplies(): Note[];
    getReply(index: number): Note;
    getReplyCount(): number;
    getReviewState(index: number): Note;
    getReviewStateCount(): number;
    getReviewStates(): Note[];
    getRichText(): Promise<Array<any>>;
    getSubject(): string;
    getTitle(): string;
    insertRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    isGrouped(): boolean;
    isGroupHeader(): Markup[];
    removeAllStateAnnots(): Promise<boolean>;
    removeRichText(indexes: number[]): void;
    setContent(content: string): Promise<Annot[]>;
    setCreateDateTime(date: number): Promise<Annot[]>;
    setIntent(intent: string): Promise<Annot[]>;
    setOpacity(opacity: number): Promise<Annot[] | boolean>;
    setRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    setSubject(subject: string): Promise<Annot[]>;
    setTitle(title: string): Promise<Annot[]>;
    getBorderColor(): number;
    getBorderInfo(): {
      cloudIntensity: number;
      dashPhase: number;
      dashes: number[];
      style: number;
      width: number;
    };
    getContent(): string;
    getDictionaryEntry(key: string): Promise<string>;
    getFlags(): number;
    getModifiedDateTime(): Date | null;
    getObjectNumber(): number;
    getPage(): PDFPage;
    getRect(): PDFRect;
    getType(): string;
    getUniqueID(): string;
    isEmpty(): boolean;
    isMarkup(): boolean;
    setBorderColor(
      borderColor: number | [string, number, number, number] | string
    ): Promise<boolean>;
    setBorderInfo(borderInfo: {
      cloudIntensity?: number;
      dashPhase?: number;
      dashes?: number[];
      style: Border_Style;
      width: number;
    }): Promise<void>;
    setDictionaryEntry(key: string, value: string): Promise<boolean>;
    setFlags(flag: number): Promise<boolean>;
    setModifiedDateTime(date: Date | number): Promise<boolean>;
    setRect(rect: PDFRect): Promise<boolean>;
  }

  class Underline extends TextMarkup {
    exportToJSON(): Record<string, any>;
    getContinuousText(): string;
    getEndCharIndex(): number;
    getQuadPoints(): Array<Array<{ x: number; y: number }>>;
    getStartCharIndex(): number;
    getText(): string;
    updateQuadPointsByCharIndex(
      startCharIndex: number,
      endCharIndex: number
    ): Promise<boolean>;
    addMarkedState(stateName: string): Promise<Note>;
    addReply(content: string): Promise<Note>;
    addReviewState(stateName: string): Promise<Note>;
    addRichText(
      datas: Array<{
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    getCreateDateTime(): Date;
    getGroupElements(): Annot[];
    getGroupHeader(): Markup;
    getIntent(): string;
    getMarkedState(index: number): Note;
    getMarkedStateCount(): number;
    getMarkedStates(): Note[];
    getOpacity(): number;
    getPopup(): Annot;
    getReplies(): Note[];
    getReply(index: number): Note;
    getReplyCount(): number;
    getReviewState(index: number): Note;
    getReviewStateCount(): number;
    getReviewStates(): Note[];
    getRichText(): Promise<Array<any>>;
    getSubject(): string;
    getTitle(): string;
    insertRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    isGrouped(): boolean;
    isGroupHeader(): Markup[];
    removeAllStateAnnots(): Promise<boolean>;
    removeRichText(indexes: number[]): void;
    setContent(content: string): Promise<Annot[]>;
    setCreateDateTime(date: number): Promise<Annot[]>;
    setIntent(intent: string): Promise<Annot[]>;
    setOpacity(opacity: number): Promise<Annot[] | boolean>;
    setRichText(
      datas: Array<{
        index: number;
        content: string;
        richTextStyle: {
          font: {
            name: string;
            styles: number;
            charset: number;
          };
          textSize: number;
          textAlignment: number;
          textColor: number;
          isBold: boolean;
          isItalic: boolean;
          isUnderline: boolean;
          isStrikethrough: boolean;
          cornerMarkStyle: number;
        };
      }>
    ): void;
    setSubject(subject: string): Promise<Annot[]>;
    setTitle(title: string): Promise<Annot[]>;
    getBorderColor(): number;
    getBorderInfo(): {
      cloudIntensity: number;
      dashPhase: number;
      dashes: number[];
      style: number;
      width: number;
    };
    getContent(): string;
    getDictionaryEntry(key: string): Promise<string>;
    getFlags(): number;
    getModifiedDateTime(): Date | null;
    getObjectNumber(): number;
    getPage(): PDFPage;
    getRect(): PDFRect;
    getType(): string;
    getUniqueID(): string;
    isEmpty(): boolean;
    isMarkup(): boolean;
    setBorderColor(
      borderColor: number | [string, number, number, number] | string
    ): Promise<boolean>;
    setBorderInfo(borderInfo: {
      cloudIntensity?: number;
      dashPhase?: number;
      dashes?: number[];
      style: Border_Style;
      width: number;
    }): Promise<void>;
    setDictionaryEntry(key: string, value: string): Promise<boolean>;
    setFlags(flag: number): Promise<boolean>;
    setModifiedDateTime(date: Date | number): Promise<boolean>;
    setRect(rect: PDFRect): Promise<boolean>;
  }

  class Widget extends Annot {
    getAction(): Action;
    getAdditionalAction(type: number): Action;
    getControl(): PDFControl;
    getField(): PDFField;
    getMKProperty(key: string): number | string;
    setAdditionalAction(trigger: number, action: Action): Promise<void>;
    setMKProperty(key: string, value: number | string): void;
    exportToJSON(): object;
    getBorderColor(): number;
    getBorderInfo(): {
      cloudIntensity: number;
      dashPhase: number;
      dashes: number[];
      style: number;
      width: number;
    };
    getContent(): string;
    getDictionaryEntry(key: string): Promise<string>;
    getFlags(): number;
    getModifiedDateTime(): Date | null;
    getObjectNumber(): number;
    getPage(): PDFPage;
    getRect(): PDFRect;
    getTitle(): string;
    getType(): string;
    getUniqueID(): string;
    isEmpty(): boolean;
    isMarkup(): boolean;
    setBorderColor(
      borderColor: number | [string, number, number, number] | string
    ): Promise<boolean>;
    setBorderInfo(borderInfo: {
      cloudIntensity?: number;
      dashPhase?: number;
      dashes?: number[];
      style: Border_Style;
      width: number;
    }): Promise<void>;
    setContent(content: string): Promise<Annot[] | Annot>;
    setDictionaryEntry(key: string, value: string): Promise<boolean>;
    setFlags(flag: number): Promise<boolean>;
    setModifiedDateTime(date: Date | number): Promise<boolean>;
    setRect(rect: PDFRect): Promise<boolean>;
  }

  export interface ComparePageRange {
    end: number;
    from: number;
  }

  export interface LineThicknessValues {
    delete: number;
    insert: number;
    replace: number;
  }

  export interface MarkingColorValues {
    delete: number;
    insert: number;
    replace: number;
  }

  export interface OpacityValues {
    delete: number;
    insert: number;
    replace: number;
  }

  enum Action_Trigger {
    click,
    keyStroke,
    format,
    validate,
    calculate,
    mouseEnter,
    mouseExit,
    mouseDown,
    mouseUp,
    onFocus,
    onBlur,
  }

  enum Action_Type {
    goto,
    launch,
    uri,
    named,
    submitForm,
    resetForm,
    javaScript,
    importData,
    hide,
  }

  enum Additional_Permission {
    download,
  }

  enum Alignment {
    left,
    center,
    right,
  }

  enum AnnotUpdatedType {
    contentUpdated,
    borderInfoUpdated,
    borderStyleUpdated,
    borderWidthUpdated,
    borderColorUpdated,
    modifiedDateTimeUpdated,
    uniqueIDUpdated,
    flagsUpdated,
    rectUpdated,
    innerRectUpdated,
    iconNameUpdated,
    rotationUpdated,
    defaultAppearanceUpdated,
    calloutLineEndingStyleUpdated,
    calloutLinePointsUpdated,
    fillColorUpdated,
    textColorUpdated,
    alignmentUpdated,
    inkListUpdated,
    endPointUpdated,
    startPointUpdated,
    endingStyleUpdated,
    enableCaptionUpdated,
    leaderCaptionOffsetUpdated,
    styleFillColorUpdated,
    leaderLineLengthUpdated,
    leaderLineExtendUpdated,
    leaderLineOffsetUpdated,
    measureRatioUpdated,
    measureUnitUpdated,
    measureConversionFactorUpdated,
    removeAction,
    actionDataUpdated,
    addAction,
    highlightingModeUpdated,
    subjectUpdated,
    titleUpdated,
    createDateTimeUpdated,
    opacityUpdated,
    intentUpdated,
    vertexesUpdated,
    applyFillColorUpdated,
    overlayTextUpdated,
    overlayTexAlignmentUpdated,
    repeatUpdated,
    autoFontSizeUpdated,
    redactDefaultAppearanceUpdated,
    redactOpacityUpdated,
    quadPointsUpdated,
    reviewStateUpdated,
    markedStateUpdated,
    statesCleared,
    replyAdded,
    richTextUpdated,
    richTextRemoved,
    addDictionary,
    formFieldValueUpdated,
    formFieldsMaxLengthUpdated,
    formFieldItemsUpdated,
    formFieldIconUpdated,
    formFieldInsertedItem,
    formFieldExportValueUpdated,
    formFieldMKPropertyUpdated,
    formFieldAlternateName,
    formFieldActionUpdated,
  }

  enum Border_Style {
    solid,
    dashed,
    underline,
    beveled,
    inset,
    cloudy,
    noBorder,
  }

  enum Box_Type {
    MediaBox,
    CropBox,
    TrimBox,
    ArtBox,
    BleedBox,
  }

  enum Calc_Margin_Mode {
    CalcContentsBox,
    CalcDetection,
  }

  enum Cipher_Type {
    cipherNone,
    cipherRC4,
    cipherAES,
  }

  enum DataEvents {
    annotationUpdated,
    annotationAppearanceUpdated,
    annotationReplyAdd,
    annotationReplyAdded,
    annotationReviewStateAnnotAdd,
    annotationReviewStateAnnotAdded,
    annotationMarkedStateAnnotAdd,
    annotationMarkedStateAnnotAdded,
    annotationStatesCleared,
    annotationRemoved,
    annotationMovedPosition,
    annotationPositionMoved,
    annotationAdded,
    annotationImported,
    actionUpdated,
    actionAdd,
    actionAdded,
    layerVisibleChange,
    layerVisibleChanged,
    bookmarkAdded,
    bookmarkUpdated,
    bookmarkRemoved,
    stateAnnotNameUpdated,
    pageInfoChange,
    pageInfoChanged,
    pageRotationChange,
    pageRotationChanged,
    imageAdded,
    watermarkAdded,
    graphicsUpdated,
    docPasswordChanged,
    drmEncryptSuccess,
    drmEncryptSucceeded,
    drmEncryptFailed,
    removePwdAndPerm,
    pwdAndPermRemoved,
    pageMoved,
    pageRemoved,
    pageAdded,
    insertPages,
    pagesInserted,
    applyRedaction,
    redactionApplied,
    removeReviewState,
    reviewStateRemoved,
    formValueChanged,
    metaDataChanged,
    docModified,
    flattened,
    headerFooterUpdated,
    headerFooterAdded,
    pagesMoved,
    pagesRemoved,
    pagesRotated,
    pageMeasureScaleRatioChanged,
    pagesBoxChanged,
  }

  enum date_Format {
    MSlashD,
    MSlashDSlashYY,
    MSlashDSlashYYYY,
    MMSlashDDSlashYY,
    MMSlashDDSlashYYYY,
    DSlashMSlashYY,
    DSlashMSlashYYYY,
    DDSlashMMSlashYY,
    DDSlashMMSlashYYYY,
    MMSlashYY,
    MMSlashYYYY,
    MDotDDotYY,
    MDotDDotYYYY,
    MMDotDDDotYY,
    MMDotDDDotYYYY,
    MMDotYY,
    DDotMDotYYYY,
    DDDotMMDotYY,
    DDDotMMDotYYYY,
    YYHyphenMMHyphenDD,
    YYYYHyphenMMHyphenDD,
  }

  enum Ending_Style {
    None,
    Square,
    Circle,
    Diamond,
    OpenArrow,
    ClosedArrow,
    Butt,
    ReverseOpenArrow,
    ReverseClosedArrow,
    Slash,
  }

  enum Error_Code {
    success,
    file,
    format,
    password,
    handle,
    certificate,
    unknown,
    invalidLicense,
    param,
    unsupported,
    outOfMemory,
    securityHandler,
    notParsed,
    notFound,
    invalidType,
    conflict,
    unknownState,
    dataNotReady,
    invalidData,
    xFALoadError,
    notLoaded,
    invalidState,
    notCDRM,
    canNotConnectToServer,
    invalidUserToken,
    noRights,
    rightsExpired,
    deviceLimitation,
    canNotRemoveSecurityFromServer,
    canNotGetACL,
    canNotSetACL,
    isAlreadyCPDF,
    isAlreadyCDRM,
    canNotUploadDocInfo,
    canNotUploadCDRMInfo,
    invalidWrapper,
    canNotGetClientID,
    canNotGetUserToken,
    invalidACL,
    invalidClientID,
    OCREngineNotInit,
    diskFull,
    OCRTrialIsEnd,
    filePathNotExist,
    complianceEngineNotInit,
    complianceEngineInvalidUnlockCode,
    complianceEngineInitFailed,
    timeStampServerMgrNotInit,
    LTVVerifyModeNotSet,
    LTVRevocationCallbackNotSet,
    LTVCannotSwitchVersion,
    LTVCannotCheckDTS,
    LTVCannotLoadDSS,
    LTVCannotLoadDTS,
    needSigned,
    complianceResourceFile,
    timeStampServerMgrNoDefaltServer,
    defaultTimeStampServer,
    noConnectedPDFModuleRight,
    noXFAModuleRight,
    noRedactionModuleRight,
    noRMSModuleRight,
    noOCRModuleRight,
    noComparisonModuleRight,
    noComplianceModuleRight,
    noOptimizerModuleRight,
    noConversionModuleRight,
  }

  enum File_Type {
    fdf,
    xfdf,
    xml,
    csv,
    txt,
  }

  enum FileAttachment_Icon {
    graph,
    pushPin,
    paperclip,
    tag,
  }

  enum Flatten_Option {
    all,
    field,
    annot,
  }

  enum Font_Charset {
    ANSI,
    Default,
    Symbol,
    Shift_JIS,
    Hangeul,
    GB2312,
    ChineseBig5,
    Thai,
    EastEurope,
    Russian,
    Greek,
    Turkish,
    Hebrew,
    Arabic,
    Baltic,
  }

  enum Font_CIDCharset {
    Unknown,
    GB1,
    CNS1,
    JAPAN1,
    KOREA1,
    UNICODE,
  }

  enum Font_Descriptor_Flags {
    FixedPitch,
    Serif,
    Symbolic,
    Script,
    Nonsymbolic,
    Italic,
    AllCap,
    SmallCap,
    ForceBold,
  }

  enum Font_StandardID {
    Courier,
    CourierB,
    CourierBI,
    CourierI,
    Helvetica,
    HelveticaB,
    HelveticaBI,
    HelveticaI,
    Times,
    TimesB,
    TimesBI,
    TimesI,
    Symbol,
    ZapfDingbats,
  }

  enum Font_Style {
    normal,
    italic,
    bold,
  }

  enum Font_Styles {
    x0001,
    x0002,
    x0004,
    x0008,
    x0020,
    x0040,
    x10000,
    x20000,
    x40000,
  }

  enum Graphics_FillMode {
    None,
    Alternate,
    Winding,
  }

  enum Graphics_ObjectType {
    All,
    Text,
    Path,
    Image,
    Shading,
    FormXObject,
  }

  enum Highlight_Mode {
    none,
    invert,
    outline,
    push,
    toggle,
  }

  enum MK_Properties {
    borderColor,
    fillColor,
    normalCaption,
  }

  enum Note_Icon {
    Check,
    Circle,
    Comment,
    Cross,
    Help,
    Insert,
    Key,
    NewParagraph,
    Note,
    Paragraph,
    RightArrow,
    RightPointer,
    Star,
    UpArrow,
    UpLeftArrow,
  }

  enum page_Number_Format {
    default,
    numberOfCount,
    numberSlashCount,
    pageNumber,
    pageNumberOfCount,
  }

  enum Point_Type {
    moveTo,
    lineTo,
    lineToCloseFigure,
    bezierTo,
    bezierToCloseFigure,
  }

  enum POS_TYPE {
    FIRST,
    LAST,
    AFTER,
    BEFORE,
  }

  enum Position {
    topLeft,
    topCenter,
    topRight,
    centerLeft,
    center,
    centerRight,
    bottomLeft,
    bottomCenter,
    bottomRight,
  }

  enum PosType {
    first,
    last,
    after,
    before,
  }

  enum Range_Filter {
    all,
    even,
    odd,
  }

  enum Relationship {
    firstChild,
    lastChild,
    previousSibling,
    nextSibling,
    firstSibling,
    lastSibling,
  }

  enum Rendering_Content {
    page,
    annot,
    form,
  }

  enum Rendering_Usage {
    print,
    view,
  }

  enum Rotation {
    rotation0,
    rotation1,
    rotation2,
    rotation3,
  }

  enum Rotation_Degree {
    rotation0,
    rotation90,
    rotation180,
    rotation270,
  }

  enum Saving_Flag {
    normal,
    incremental,
    noOriginal,
    XRefStream,
    linearized,
    removeRedundantObjects,
  }

  enum Search_Flag {
    caseSensitive,
    wholeWord,
    consecutively,
  }

  enum Signature_Ap_Flags {
    showTagImage,
    showLabel,
    showReason,
    showDate,
    showDistinguishName,
    showLocation,
    showSigner,
    showBitmap,
    showText,
  }

  enum Signature_State {
    verifyChange,
    verifyIncredible,
    verifyNoChange,
    stateVerifyIssueUnknown,
    verifyIssueValid,
    verifyIssueUnknown,
    verifyIssueRevoke,
    verifyIssueExpire,
    verifyIssueUncheck,
    verifyIssueCurrent,
    verifyTimestampNone,
    verifyTimestampDoc,
    verifyTimestampValid,
    verifyTimestampInvalid,
    verifyTimestampExpire,
    verifyTimestampIssueUnknown,
    verifyTimestampIssueValid,
    verifyTimestampTimeBefore,
    verifyChangeLegal,
    verifyChangeIllegal,
  }

  enum Sound_Icon {
    speaker,
    mic,
    ear,
  }

  enum STAMP_TEXT_TYPE {
    CUSTOM_TEXT,
    NAME,
    NAME_DATE_TIME,
    DATE_TIME,
    DATE,
  }

  enum Standard_Font {
    courier,
    courierBold,
    courierBoldOblique,
    courierOblique,
    helvetica,
    helveticaBold,
    helveticaBoldOblique,
    helveticaOblique,
    timesRoman,
    timesBold,
    timesBoldItalic,
    timesItalic,
    symbol,
    zapfDingbats,
  }

  enum Text_Mode {
    Fill,
    Stroke,
    FillStroke,
    Invisible,
    FillClip,
    StrokeClip,
    FillStrokeClip,
    Clip,
  }

  enum User_Permissions {
    print,
    modify,
    extract,
    annotForm,
    fillForm,
    extractAccess,
    assemble,
    printHigh,
  }

  enum Watermark_Flag {
    asContent,
    asAnnot,
    onTop,
    unprintable,
    display,
  }

  enum ZoomMode {
    ZoomXYZ,
    ZoomFitPage,
    ZoomFitHorz,
    ZoomFitRect,
  }

  enum Field_Flag {
    ReadOnly,
    Required,
    NoExport,
    Hidden,
    ButtonNoToggleToOff,
    ButtonRadiosInUnison,
    TextMultiline,
    TextPassword,
    TextDoNotSpellCheck,
    TextDoNotScroll,
    TextComb,
    ComboEdit,
    ChoiceMultiSelect,
    CommitOnSelChange,
  }

  enum Field_Type {
    Unknown,
    PushButton,
    CheckBox,
    RadioButton,
    Text,
    ListBox,
    ComboBox,
    Sign,
    Barcode,
  }

  class PDFControl {
    getDefaultAppearance(): {
      textColor: number;
      textSize: number;
      fontName: string;
    };
    getField(): PDFField;
    getIndex(): Promise<number>;
    getWidgetAnnot(): Promise<Widget>;
    setDefaultAppearance(defaultAppearance: {
      fontName: string;
      textColor: number;
      textSize: number;
    }): Promise<void>;
  }

  class PDFField {
    getAlignment(): number;
    getAlternateName(): string;
    getBorderColor(): number;
    getBorderStyle(): string;
    getControlByIndex(index: number): PDFControl;
    getControlsCount(): number;
    getDAFontSize(): number;
    getFillColor(): number;
    getFlags(): number;
    getMaxLength(): number;
    getName(): string;
    getOptions(): Array<{ label: string; value: string }>;
    getType(): number;
    getValue(): string;
    setAction(trigger: number, action: string | Action): Promise<void>;
    setAlignment(alignment: number): Promise<void>;
    setBorderColor(
      borderColor: number | [string, number, number, number] | string
    ): Promise<boolean>;
    setBorderStyle(style: string): Promise<void>;
    setFillColor(
      fillColor: number | ['T'] | [string, number, number, number] | string
    ): Promise<void>;
    setFlags(flags: number): void;
    setMaxLength(maxLength: number): void;
    setOptions(
      options: Array<{
        label: string;
        value: string;
        selected: boolean;
        defaultSelected: boolean;
      }>
    ): Promise<void>;
    setValue(value: string, control: Annot): void;
  }

  class PDFForm {
    addControl(
      pageIndex: number,
      fieldName: string,
      fieldType: number,
      rect: PDFRect
    ): Promise<{ success: boolean; newFieldName: string }>;
    addSignature(
      pageIndex: number,
      rect: PDFRect,
      fieldName: string
    ): Promise<PDFField>;
    calculate(field: PDFField): void;
    getField(title: string): PDFField[];
    getFieldByIndex(index: number): PDFField;
    getFieldCount(): number;
    removeField(fieldName: string): Promise<boolean>;
    resetForm(fieldNames: string[], flags: number, source: PDFField): void;
  }

  class PDFSignature extends PDFField {
    getByteRange(): number[];
    getFilter(): string;
    getSignInfo(): Record<string, any>;
    getSubfilter(): string;
    isSigned(): boolean;
    getAlignment(): number;
    getAlternateName(): string;
    getBorderColor(): number;
    getBorderStyle(): string;
    getControlByIndex(index: number): PDFControl;
    getControlsCount(): number;
    getDAFontSize(): number;
    getFillColor(): number;
    getFlags(): number;
    getMaxLength(): number;
    getName(): string;
    getOptions(): Array<{ label: string; value: string }>;
    getType(): number;
    getValue(): string;
    setAction(trigger: number, action: string | Action): Promise<void>;
    setAlignment(alignment: number): Promise<void>;
    setBorderColor(
      borderColor: number | [string, number, number, number] | string
    ): Promise<boolean>;
    setBorderStyle(style: string): Promise<void>;
    setFillColor(
      fillColor: number | ['T'] | [string, number, number, number] | string
    ): Promise<void>;
    setFlags(flags: number): void;
    setMaxLength(maxLength: number): void;
    setOptions(
      options: Array<{
        label: string;
        value: string;
        selected: boolean;
        defaultSelected: boolean;
      }>
    ): Promise<void>;
    setValue(value: string, control: Annot): void;
  }

  class DocTextSearch {
    destroy(): void;
    findNext(): Promise<TextSearchMatch | null>;
    findPrev(): Promise<TextSearchMatch | null>;
    getId(): string;
    setCurrentPageIndex(index: number): void;
    setEndPageIndex(index: number): void;
    setStartPageIndex(index: number): void;
  }

  class PageTextSearch {
    destroy(): Promise<void>;
    findNext(): Promise<TextSearchMatch | null>;
    findPrev(): Promise<TextSearchMatch | null>;
  }

  class TextSearchMatch {
    getEndCharIndex(): number;
    getPageIndex(): number;
    getRects(): Array<{
      left: number;
      right: number;
      bottom: number;
      top: number;
    }>;
    getSentence(): string;
    getSentenceStartIndex(): number;
    getStartCharIndex(): number;
  }

  export interface TaskProgress<T extends TaskProgressData> {
    cancel(): void;
    getCurrentProgress(): number;
    onProgress(callback: (this: TaskProgress<T>, data: T) => void): () => void;
  }

  export interface TaskProgressData {
    percent: number;
  }

  class GraphicsObject {
    getBitmap(
      scale: number,
      rotation: number,
      type?: 'canvas' | 'image' | 'buffer'
    ): Promise<HTMLCanvasElement | HTMLImageElement | ArrayBuffer>;
    getBorderColor(): number;
    getBorderDashes(): number[];
    getBorderStyle(): number;
    getBorderWidth(): number;
    getDeviceMatrix(): Matrix;
    getFillColor(): number;
    getId(): string;
    getMatrix(): Matrix;
    getOpacity(): number;
    getPDFPage(): PDFPage;
    getRect(): PDFRect;
    getType(): number;
    moveToPosition(type: PosType, graphicObject: object): Promise<void>;
    setBorderColor(value: number): Promise<void>;
    setBorderStyle(value: number, dashes: number[]): Promise<void>;
    setBorderWidth(value: number): Promise<void>;
    setFillColor(value: number): Promise<void>;
    setMatrix(): Matrix;
    setOpacity(value: number): Promise<void>;
    setRect(rect: PDFRect): void;
  }

  class HeaderFooter {
    constructor(json?: object);

    enableFixedSizedForPrint(enable: boolean): void;
    enableTextShrinked(enable: boolean): void;
    getContent(position: string): void;
    getUnderline(): boolean;
    isEmpty(): boolean;
    setContentFormat(
      position: string,
      format: Array<{ type: string; value: any }>
    ): void;
    setFont(fontId: number): void;
    setMargin(rect: PDFRect): void;
    setRange(range: PageRange): void;
    setStartDisplayingPage(index: number): void;
    setTextColor(color: number): void;
    setTextSize(size: number): void;
    setUnderline(underline: boolean): void;
  }

  export interface ILayerNode {
    children: ILayerNode | [];
    hasLayer: boolean;
    id: string;
    isLocked: boolean;
    name: string;
    visible: boolean;
  }

  class ImageObject extends GraphicsObject {
    setRotation(rotation: number): Record<string, any>;
    getBitmap(
      scale: number,
      rotation: number,
      type?: 'canvas' | 'image' | 'buffer'
    ): Promise<HTMLCanvasElement | HTMLImageElement | ArrayBuffer>;
    getBorderColor(): number;
    getBorderDashes(): number[];
    getBorderStyle(): number;
    getBorderWidth(): number;
    getDeviceMatrix(): Matrix;
    getFillColor(): number;
    getId(): string;
    getMatrix(): Matrix;
    getOpacity(): number;
    getPDFPage(): PDFPage;
    getRect(): PDFRect;
    getType(): number;
    moveToPosition(type: PosType, graphicObject: object): Promise<void>;
    setBorderColor(value: number): Promise<void>;
    setBorderStyle(value: number, dashes: number[]): Promise<void>;
    setBorderWidth(value: number): Promise<void>;
    setFillColor(value: number): Promise<void>;
    setMatrix(): Matrix;
    setOpacity(value: number): Promise<void>;
    setRect(rect: PDFRect): void;
  }

  class Matrix {
    constructor(
      a: number,
      b: number,
      c: number,
      d: number,
      e: number,
      f: number
    );

    concat(
      a: number | Matrix | [number, number, number, number, number, number],
      b: number,
      c: number,
      d: number,
      e: number,
      f: number,
      bPrepended: boolean
    ): void;
    getA(): number;
    getAngle(): number;
    getB(): number;
    getC(): number;
    getD(): number;
    getE(): number;
    getF(): number;
    getUnitRect(): number[];
    getXUnit(): number;
    getYUnit(): number;
    is90Rotated(): void;
    isScaled(): void;
    matchRect(dest: number[], src: number[]): void;
    reset(): void;
    reverse(matrix: Matrix): Matrix;
    rotate(fRadian: number, bPrepended: boolean): void;
    rotateAt(
      dx: number,
      dy: number,
      fRadian: number,
      bPrepended: boolean
    ): void;
    scale(sx: number, sy: number, bPrepended: boolean): void;
    set(a: number, b: number, c: number, d: number, e: number, f: number): void;
    setReverse(matrix: Matrix): void;
    transformDistance(dx: number, dy: number): number;
    transformPoint(dx: number, dy: number): number[];
    transformRect(
      left: number,
      top: number,
      right: number,
      bottom: number
    ): number[];
    transformXDistance(dx: number): number;
    transformYDistance(dy: number): number;
    translate(x: number, y: number, bPrepended: boolean): void;
    static Concat2mt(matrix1: Matrix, matrix2: Matrix): Matrix;
  }

  class PathObject extends GraphicsObject {
    getFillMode(): number;
    getPathPoints(): Array<{ x: number; y: number }>;
    needStroke(): boolean;
    getBitmap(
      scale: number,
      rotation: number,
      type?: 'canvas' | 'image' | 'buffer'
    ): Promise<HTMLCanvasElement | HTMLImageElement | ArrayBuffer>;
    getBorderColor(): number;
    getBorderDashes(): number[];
    getBorderStyle(): number;
    getBorderWidth(): number;
    getDeviceMatrix(): Matrix;
    getFillColor(): number;
    getId(): string;
    getMatrix(): Matrix;
    getOpacity(): number;
    getPDFPage(): PDFPage;
    getRect(): PDFRect;
    getType(): number;
    moveToPosition(type: PosType, graphicObject: object): Promise<void>;
    setBorderColor(value: number): Promise<void>;
    setBorderStyle(value: number, dashes: number[]): Promise<void>;
    setBorderWidth(value: number): Promise<void>;
    setFillColor(value: number): Promise<void>;
    setMatrix(): Matrix;
    setOpacity(value: number): Promise<void>;
    setRect(rect: PDFRect): void;
  }

  class PDFBookmark {
    children: PDFBookmark | [];
    color: string;
    id: number;
    isBold: number;
    isItalic: number;
    left: number;
    page: number;
    title: number;
    top: number;
    insertBookmark(
      title: string,
      pageIndex: number,
      top: number,
      left: number,
      relationship?: Relationship
    ): Promise<PDFBookmark | null>;
    remove(): Promise<boolean>;
    setProperty(properties: {
      title: string;
      color: number | [string, number, number, number] | string;
      style: number;
    }): Promise<PDFBookmark>;
  }

  class PDFDictionary {
    getAt(key: string): Promise<number | boolean | string>;
    hasKey(key: string): Promise<boolean>;
    setAt(key: string, value: number | boolean | string): Promise<boolean>;
  }

  class PDFDoc extends Disposable {
    addAnnot(pageIndex: number, annotJson: object): Promise<Annot[]>;
    addAnnotGroup(
      pageIndex: number,
      annotJsons: object,
      headerIndex: number
    ): Promise<Annot[]>;
    addHeaderFooter(headerfooter: HeaderFooter): Promise<object>;
    addWatermark(watermarkConfig: {
      pageStart: number;
      pageEnd: number;
      type: 'text' | 'bitmap';
      text?: string;
      bitmap?: Uint8Array;
      absScale?: number;
      useRelativeScale?: boolean;
      isMultiline?: boolean;
      rowSpace?: number;
      columnSpace?: number;
      watermarkSettings: {
        position?: Position;
        offsetX?: number;
        offsetY?: number;
        flags: Watermark_Flag;
        scale?: number;
        rotation?: number;
        opacity?: number;
      };
      watermarkTextProperties?: {
        font?: Standard_Font | number;
        fontSize?: number;
        color?: number;
        fontStyle?: 'normal' | 'underline';
      };
    }): void;
    applyRedaction(): Promise<false | Array<Array<Annot>>>;
    createRootBookmark(): Promise<PDFBookmark>;
    drmEncrypt(drmOptions: {
      isEncryptMetadata?: boolean;
      subFilter: string;
      cipher: number;
      keyLength: number;
      isOwner: boolean;
      userPermissions: number;
      fileId: string;
      initialKey: string;
      values?: object;
    }): void;
    exportAnnotsToFDF(fileType: number, annots?: Annot[]): Promise<Blob>;
    exportAnnotsToJSON(annots: Array<Annot>): Promise<IAnnotationSummary[]>;
    exportFormToFile(fileType: number): Promise<Blob>;
    extractPages(pageRange: number[][]): Promise<ArrayBuffer[]>;
    flatten(option: number): Promise<boolean[]>;
    getAllBoxesByPageIndex(index: number): Promise<{
      mediaBox: PDFRect; // Media Box for page boundary
      cropBox: PDFRect; // Crop Box for page boundary
      trimBox: PDFRect; // Trim Box for page boundary
      artBox: PDFRect; // Art Box for page boundary
      bleedBox: PDFRect; // Bleed Box for page boundary
      calcBox: PDFRect; // Content area of PDF page
      minWidth: number; // Minimum media box width of all pages
      minHeight: number; // Minimum media box height of all pages
      width: number; // Media box height of current page
      height: number; // Media box height of current page
    }>;
    getAnnots(): Promise<Annot[]>;
    getBookmarksJson(): Promise<Object>;
    getComparisonFilterCountSummary(): {
      Images: number;
      Formatting: number;
      Text: number;
      Annotation: number;
    };
    getEmbeddedFileNames(): string[];
    getFile(options?: { flags?: number; fileName?: string }): Promise<File>;
    getFontsInfo(): Promise<Array<Record<string, any>>>;
    getHeaderFooter(): Promise<HeaderFooter>;
    getId(): string;
    getInfo(): Promise<PDFDictionary>;
    getLayerNodesJson(): Promise<ILayerNode>;
    getMetadata(): Promise<object>;
    getPageAnnots(index: number): Promise<Annot[]>;
    getPageByIndex(index: number): Promise<PDFPage>;
    getPageCount(): number;
    getPageLabels(pageIndexes: number[]): Promise<string[]>;
    getPasswordType(): Promise<number>;
    getPDFForm(): PDFForm;
    getPermission(): Promise<number>;
    getPermissions(): number;
    getRootBookmark(): Promise<PDFBookmark>;
    getStream(
      writeChunk: (options: {
        arrayBuffer: ArrayBuffer;
        offset: number;
        size: number;
      }) => void,
      flag: number
    ): Promise<number>;
    getText(pages: number[][]): TaskProgress<TaskProgressData>;
    getTextSearch(pattern: string, flags: number): DocTextSearch;
    getUserPermissions(): number;
    hasForm(): Promise<boolean>;
    importAnnotsFromFDF(
      fdf: File | Blob | ArrayBuffer | TypedArray | DataView,
      escape?: boolean
    ): Promise<void>;
    importAnnotsFromJSON(annotsJson: IAnnotationSummary[]): Promise<void>;
    importFormFromFile(
      file: File | Blob | ArrayBuffer | TypedArray | DataView,
      format: File_Type,
      encoding?: string
    ): Promise<void>;
    insertBlankPages(
      pageRange: number[][],
      width: number,
      height: number
    ): Promise<PDFPage[]>;
    insertPage(
      pageIndex: number,
      width: number,
      height: number
    ): Promise<PDFPage>;
    insertPages(insertOptions: {
      destIndex: number;
      file: File | Blob | ArrayBuffer | TypedArray | DataView;
      password?: string;
      flags?: number;
      layerName?: string;
      startIndex: number;
      endIndex: number;
    }): Promise<PDFPage[]>;
    isCompareDoc(): boolean;
    isDocModified(): boolean;
    isLinearized(): Promise<boolean>;
    loadPDFForm(): Promise<PDFForm>;
    loadThumbnail(options: {
      pageIndex: number;
      scale?: number;
      rotation?: number;
      type?: 'canvas' | 'image' | 'buffer';
      width?: number;
      height?: number;
    }): Promise<HTMLCanvasElement | HTMLImageElement | ArrayBuffer>;
    makeRedactByPages(pages: number[]): Promise<Array<Annot>>;
    mergePDFDoc(options: {
      doc: PDFDoc;
      insertIndex?: number;
      pages?: number[];
      layerName?: string;
    }): Promise<void>;
    movePagesTo(pageRange: number[][], destIndex: number): Promise<string[]>;
    movePageTo(pageIndex: number, destIndex: number): Promise<boolean>;
    removeAllEmbeddedFiles(): Promise<boolean>;
    removeEmbeddedFileByName(name: string): Promise<boolean>;
    removeHeaderFooter(): Promise<void>;
    removePage(pageIndex: number): Promise<boolean>;
    removePages(pageRange: string[][]): Promise<boolean>;
    rotatePages(pageRange: number[][], rotation: number): Promise<void>;
    searchText(
      pages: number[],
      words: string[],
      options?: { wholeWordsOnly?: boolean; caseSensitive?: boolean }
    ): object;
    setLayerNodeVisible(
      layerId: string | number,
      visiable: boolean
    ): Promise<boolean>;
    setMetadataValue(key: string, value: string): void;
    setPagesBox(options: {
      indexes: number[];
      width?: number;
      height?: number;
      offsetX?: number;
      offsetY?: number;
      boxes?: {
        cropBox?: PDFRect;
        artBox?: PDFRect;
        trimBox?: PDFRect;
        bleedBox?: PDFRect;
      };
      removeWhiteMargin?: boolean;
    }): Promise<void>;
    setPasswordAndPermission(
      userPassword: string,
      ownerPassword: string,
      permission?: number,
      cipher?: 'none' | 'rc4' | 'aes128' | 'aes256',
      isEncryptMetadata?: boolean
    ): Promise<boolean>;
    sign(
      signInfo: {
        filter: object;
        subfilter: object;
        rect?: PDFRect;
        pageIndex?: number;
        rotation?: 0 | 90 | 180 | 270;
        flag?: number;
        signer?: string;
        reason?: string;
        email?: string;
        image?: string;
        distinguishName?: string;
        location?: string;
        text?: string;
        defaultContentsLength?: number;
        fieldName?: string;
        timeFormat?: {
          format?: string;
          timeZoneOptions?: {
            separator?: string;
            prefix?: string;
            showSpace?: boolean;
          };
        };
      },
      DigestSignHandler: (
        signInfo: Record<string, any>,
        plainContent: Blob
      ) => Promise<ArrayBuffer>
    ): Promise<ArrayBuffer>;
    updateHeaderFooter(headerFooter: HeaderFooter): Promise<void>;
    verifySignature(
      field: PDFField,
      VerifyHandler: (
        signatureField: any,
        plainBuffer: any,
        signedData: any,
        hasDataOutOfScope: any
      ) => Promise<number>
    ): Signature_State;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
    destroy(): void;
  }

  class PDFPage {
    addAnnot(
      annotJson: {
        type: Annot_Type;
        rect: {
          left: number;
          bottom: number;
          right: number;
          top: number;
        };
        borderInfo?: {
          width?: number;
          style?: number;
          cloudIntensity?: number;
          dashPhase?: number;
          dashes?: number[];
        };
        alignment?: number;
        buffer?: Uint8Array;
        calloutLinePoints?: number[];
        calloutLineEndingStyle?: number;
        color?: string;
        contents?: string;
        coords?: Array<{
          left: number;
          top: number;
          right: number;
          bottom: number;
        }>;
        creationTimestamp?: number;
        date?: number;
        dicts?: object;
        defaultAppearance?: {
          textColor?: number;
          textSize?: number;
        };
        endCharIndex?: number;
        endPoint?: {
          x?: number;
          y?: number;
        };
        measure?: {
          unit?: string;
          ratio?: {
            userSpaceValue?: number;
            userSpaceUnit?: string;
            realValue?: number;
            realUnit?: string;
          };
        };
        endStyle?: Ending_Style;
        fileName?: string;
        contentType?: string;
        fillColor?: string;
        iconInfo?: {
          annotType?: string;
          category?: string;
          name?: string;
          fileType?: string;
          url?: string;
        };
        icon?: string;
        iconCategory?: string;
        inkList?: Array<{ x: number; y: number; type: 1 | 2 | 3 }>;
        intent?: string;
        multiBuffer?: Uint8Array;
        name?: string;
        noPopup?: boolean;
        opacity?: number;
        startCharIndex?: number;
        startStyle?: number;
        startPoint?: {
          x?: number;
          y?: number;
        };
        length?: number;
        styleFillColor?: string;
        subject?: string;
        title?: string;
        vertexes?: Array<{ x: number; y: number }>;
        rotation?: number;
        richText?: string[];
      },
      richTextData?: {
        content?: string;
        richTextStyle?: {
          font?: {
            name?: string;
            styles?: number;
            charset?: number;
          };
          textSize?: number;
          textAlignment?: number;
          textColor?: number;
          isBold?: boolean;
          isItalic?: boolean;
          isUnderline?: boolean;
          isStrikethrough?: boolean;
          cornerMarkStyle?: number;
        };
      }
    ): Promise<Annot[]>;
    addAnnotGroup(
      annotJsons: Array<object>,
      headerIndex: number
    ): Promise<Annot[]>;
    addGraphicsObject(info: {
      type: Graphics_ObjectType;
      buffer?: ArrayBuffer;
      rect?: PDFRect;
      points?: Array<[string, number, number]>;
      borderWidth?: number;
      originPosition?: PDFPoint;
      charspace?: number;
      wordspace?: number;
      textmatrix?: [number, number, number, number];
      textmode?: number;
      font?: {
        standardId?: Font_StandardID;
        name?: string;
        styles?: Font_Styles;
        charset?: Font_Charset | Font_CIDCharset;
        weight?: number;
      };
      matrix?: [number, number, number, number, number, number];
      text?: string;
      fillColor?: number;
    }): Promise<void>;
    addImage(
      imageBuffer: ArrayBuffer,
      rect: PDFRect,
      rotation?: number
    ): Promise<ImageObject | undefined | null>;
    addWatermark(watermarkConfig: {
      type: 'text' | 'bitmap';
      text?: string;
      bitmap?: Uint8Array;
      useRelativeScale?: boolean;
      watermarkSettings: {
        position?: Position;
        offsetX?: number;
        offsetY?: number;
        Watermark_Flag: number;
        scale?: number;
        rotation?: number;
        opacity?: number;
      };
      watermarkTextProperties?: {
        font?: Standard_Font;
        fontSize?: number;
        color?: number;
        fontStyle?: 'normal' | 'underline';
      };
    }): void;
    flatten(option: number): Promise<boolean>;
    getAllBoxes(): Promise<{
      mediaBox: PDFRect; // Media Box for page boundary
      cropBox: PDFRect; // Crop Box for page boundary
      trimBox: PDFRect; // Trim Box for page boundary
      artBox: PDFRect; // Art Box for page boundary
      bleedBox: PDFRect; // Bleed Box for page boundary
      calcBox: PDFRect; // Content area of PDF page, refer to
      minWidth: number; // Min width of all boxes
      minHeight: number; // Min height of all boxes
    }>;
    getAnnotCount(): number;
    getAnnotIdAtDevicePoint(
      point: [number, number],
      tolerance: number,
      matrix: Matrix
    ): Promise<string>;
    getAnnotObjectNumAtDevicePoint(
      point: [number, number],
      tolerance: number,
      matrix: Matrix
    ): Promise<number>;
    getAnnots(): Promise<Annot[]>;
    getAnnotsByIdArray(ids: string[]): Promise<Annot[]>;
    getAnnotsByObjectNumArray(objNums: number[]): Promise<Annot[]>;
    getAnnotTree(): Promise<Annot[]>;
    getBatchProcessor(): PDFPageBatchProcessor;
    getCharInfoAtPoint(
      point: [number, number],
      tolerance: number
    ): Promise<{
      charIndex: number;
      left: number;
      right: number;
      top: number;
      bottom: number;
    }>;
    getDeviceMatrix(rotate?: number): Matrix;
    getDevicePoint(
      point: [number, number],
      scale?: number,
      rotate?: number
    ): [number, number];
    getDeviceRect(
      pdfRect: PDFRect,
      scale?: number,
      rotate?: number
    ): DeviceRect;
    getDict(): Promise<PDFDictionary>;
    getGraphicsObjectAtPoint(
      point: [number, number],
      tolerance: number,
      type: Graphics_ObjectType
    ): Promise<GraphicsObject>;
    getGraphicsObjectByIndex(index: number): Promise<GraphicsObject>;
    getGraphicsObjectsByRect(options: {
      rect: PDFRect;
      tolerance: number;
      type: Graphics_ObjectType;
      isInRect?: boolean;
    }): Promise<GraphicsObject[]>;
    getGraphicsObjectsCount(): Promise<number>;
    getGraphicsObjectsInRect(
      rect: PDFRect,
      tolerance: number,
      type: Graphics_ObjectType
    ): Promise<GraphicsObject[]>;
    getHeight(): number;
    getIndex(): number;
    getMarkupAnnots(): Promise<Markup[]>;
    getMeasureScaleRatio(): Promise<{
      scale: number;
      ratio: number;
      ratioMap: Array<{ value: number; unit: string }>;
      unitName: string;
    }>;
    getPageBox(boxType: Box_Type): Promise<PDFRect>;
    getPDFDoc(): PDFDoc;
    getPDFMatrix(): Matrix;
    getRotation(): number;
    getRotationAngle(): number;
    getSnappedPoint(
      point: {
        x: number;
        y: number;
      },
      mode: SNAP_MODE
    ): Promise<{ x: number; y: number; type: SNAP_MODE }>;
    getTextContinuousRectsAtPoints(
      point1: [number, number],
      point2: [number, number],
      tolerance: number,
      start: number,
      end: number
    ): Promise<PDFRect[]>;
    getTextInRect(rect: PDFRect, type?: 0 | 1 | 2): Promise<object>;
    getTextRectsAtRect(rect: PDFRect): Promise<PDFRect[]>;
    getTextSearch(pattern: String, flags: Search_Flag): Promise<PageTextSearch>;
    getThumb(
      rotate: number
    ): Promise<{ buffer: Uint8Array; width: number; height: number }>;
    getViewportRect(): PDFRect;
    getWidth(): number;
    isCropped(): boolean;
    isVirtual(): boolean;
    markRedactAnnot(
      rects: Array<{ left: number; right: number; top: number; bottom: number }>
    ): Promise<Annot[]>;
    pasteAnnot(
      srcAnnot: Annot,
      position: { x: number; y: number }
    ): Promise<Annot[]>;
    removeAllAnnot(): Promise<Annot[]>;
    removeAnnotById(id: string): Promise<Array<Annot>>;
    removeAnnotByObjectNumber(objNum: number): Promise<Annot[]>;
    removeGraphicsObject(obj: GraphicsObject): Promise<void>;
    render(
      scale?: number,
      rotate?: number,
      area?: {
        x?: number;
        y?: number;
        width?: number;
        height?: number;
      },
      contentsFlags?: string[],
      usage?: string
    ): Promise<{
      width: number;
      height: number;
      buffer?: ArrayBuffer;
      image?: Blob;
    }>;
    reverseDeviceOffset(
      offset: number[],
      scale?: number,
      rotate?: number
    ): number[];
    reverseDevicePoint(
      point: number[],
      scale?: number,
      rotate?: number
    ): number[];
    reverseDeviceRect(pdfRect: DeviceRect, scale?: number): PDFRect;
    setMeasureScaleRatio(
      storeInPage: boolean,
      unitName: string,
      ratio: string,
      scale: number
    ): Promise<Annot[]>;
    setPageSize(width: number, height: number): Promise<void>;
    setRotation(rotation: number): void;
  }

  class PDFPageBatchProcessor {
    end(): Promise<void>;
    flush(): Promise<void>;
    start(): Promise<void>;
  }

  class TextObject extends GraphicsObject {
    getFontInfo(): Record<string, any>;
    getFontSize(): number;
    getText(): string;
    isBold(): boolean;
    isItalic(): boolean;
    setBold(bold: boolean): void;
    setFontByName(
      name: string,
      styles: Font_Styles,
      charset: Font_Charset | Font_CIDCharset
    ): void;
    setFontSize(): number;
    setItalic(italic: boolean): void;
    setStandardFont(id: number): void;
    setText(char: string): void;
    getBitmap(
      scale: number,
      rotation: number,
      type?: 'canvas' | 'image' | 'buffer'
    ): Promise<HTMLCanvasElement | HTMLImageElement | ArrayBuffer>;
    getBorderColor(): number;
    getBorderDashes(): number[];
    getBorderStyle(): number;
    getBorderWidth(): number;
    getDeviceMatrix(): Matrix;
    getFillColor(): number;
    getId(): string;
    getMatrix(): Matrix;
    getOpacity(): number;
    getPDFPage(): PDFPage;
    getRect(): PDFRect;
    getType(): number;
    moveToPosition(type: PosType, graphicObject: object): Promise<void>;
    setBorderColor(value: number): Promise<void>;
    setBorderStyle(value: number, dashes: number[]): Promise<void>;
    setBorderWidth(value: number): Promise<void>;
    setFillColor(value: number): Promise<void>;
    setMatrix(): Matrix;
    setOpacity(value: number): Promise<void>;
    setRect(rect: PDFRect): void;
  }

  class Color {
    asArray(): [number, number, number, number];
    clone(): Color;
    isSameAs(other: Color): boolean;
    toCMYK(): { c: number; m: number; y: number; k: number };
    toHSL(): { h: number; s: number; l: number };
    toHSV(): { h: number; s: number; v: number };
    static fromARGB(argb: number): Color;
    static fromHSLA(h: number, s: number, l: number, a: number): Color;
    static fromRGB(rgb: number): Color;
    static fromRGBA(rgb: number, a: number): Color;
  }

  function getRanges(intervals: Array<[number, number] | number>): number[];

  function getUnitByName(unitName: string): Unit;

  export interface StampInfo {
    category: string;
    fileType: string;
    height: number;
    iconName: string;
    width: number;
  }

  export interface StampService {
    getCurrentStampInfo(): StampInfo | undefined;
    onSelectStampInfo(
      callback: (stampInfo: StampInfo | undefined) => void
    ): () => void;
  }

  class CreateAnnotAddon {
    constructor(pdfViewer: PDFViewer);

    init(options?: {
      showReplyDialog?: () => void;
      hideReplyDialog?: () => void;
      showPopup?: () => void;
      hidePopup?: () => void;
      showPropertiesDialog?: () => void;
      hidePropertiesDialog?: () => void;
      contextMenuIsEnable?: () => void;
    }): void;
  }

  export interface AddMarkedStateCollaborationData {
    action: COLLABORATION_ACTION;
    data: AddMarkedStateOperationData;
    fileId: string | [];
    version: number;
  }

  export interface AddMarkedStateOperationData {
    annotId: string;
    pageIndex: number;
    stateAnnotJSON: Object;
  }

  export interface AddReplyCollaborationData {
    action: COLLABORATION_ACTION;
    data: AddReplyOperationData;
    fileId: string | [];
    version: number;
  }

  export interface AddReplyOperationData {
    annotId: string;
    pageIndex: number;
    reply: Object;
  }

  export interface AddReviewStateCollaborationData {
    action: COLLABORATION_ACTION;
    data: AddReviewStateOperationData;
    fileId: string | [];
    version: number;
  }

  export interface AddReviewStateOperationData {
    annotId: string;
    pageIndex: number;
    stateAnnotJSON: Object;
  }

  export interface CollaborationCommunicator {
    connect(shareId: string): Promise<boolean>;
    createSession(doc: PDFDoc): Promise<string>;
    destroy(): void;
    disconnect(): Promise<boolean>;
    getLostData(
      shareId: string,
      fromVersion: number
    ): Promise<CollaborationData[]>;
    getSessionInfo(
      shareId: string
    ): Promise<CollaborationSessionInfo | undefined>;
    isConnected(): Promise<boolean>;
    registerLostConnectionListener(receiver: () => void): void;
    registerMessageReceiver(receiver: (data: string) => void): void;
    send(shareId: string, data: string): Promise<void>;
  }

  export interface CollaborationData {}

  export interface CollaborationDataHandler<CollaborationData> {
    accept(data: CollaborationData): Promise<boolean>;
    receive(
      data: CollaborationData,
      nextHandler: CollaborationDataHandler<CollaborationData>
    ): Promise<void>;
  }

  export interface CollaborationSessionInfo {
    openFileParams: Object;
    shareId: string;
  }

  export interface CreateAnnotationCollaborationData {
    action: COLLABORATION_ACTION;
    data: CreateAnnotationOperationData;
    fileId: string | [];
    version: number;
    string(): void;
  }

  export interface CreateAnnotationOperationData {
    annots: Object | [];
  }

  export interface ImportAnnotationsFileCollaborationData {
    action: COLLABORATION_ACTION;
    data: ImportAnnotationsFileOperationData;
    fileId: string | [];
    version: number;
  }

  export interface ImportAnnotationsFileOperationData {
    file: string;
  }

  export interface MoveAnnotsBetweenPageCollaborationData {
    action: COLLABORATION_ACTION;
    data: MoveAnnotsBetweenPageOperationData;
    fileId: string | [];
    version: number;
  }

  export interface MoveAnnotsBetweenPageOperationData {
    annots: Object;
    fromPageIndex: number;
    toPageIndex: number;
  }

  export interface PPOInsertPageCollaborationData {
    action: COLLABORATION_ACTION;
    data: PPOInsertPageOperationData;
    fileId: string | [];
    version: number;
  }

  export interface PPOInsertPageOperationData {
    height: number;
    pageIndex: number;
    width: number;
  }

  export interface PPOMovePageCollaborationData {
    action: COLLABORATION_ACTION;
    data: PPOMovePageOperationData;
    fileId: string | [];
    version: number;
  }

  export interface PPOMovePageOperationData {
    destIndex: number;
    sourceIndex: number;
  }

  export interface PPORemovePageCollaborationData {
    action: COLLABORATION_ACTION;
    data: PPORemovePageOperationData;
    fileId: string | [];
    version: number;
  }

  export interface PPORemovePageOperationData {
    pageIndex: number;
  }

  export interface PPORemovePagesCollaborationData {
    action: COLLABORATION_ACTION;
    data: PPORemovePagesOperationData;
  }

  export interface PPORemovePagesOperationData {
    pageRange: number | [][];
  }

  export interface PPORotatePageCollaborationData {
    action: COLLABORATION_ACTION;
    data: COLLABORATION_ACTION;
    fileId: string | [];
    version: number;
  }

  export interface PPORotatePageOperationData {
    angle: number;
    pageIndex: number;
  }

  export interface RemoveAnnotationCollaborationData {
    action: COLLABORATION_ACTION;
    data: Array<RemoveAnnotationOperationData>;
    fileId: string | [];
    version: number;
  }

  export interface RemoveAnnotationOperationData {
    annotId: string;
    pageIndex: number;
  }

  export interface RemoveReplyCollaborationData {
    action: COLLABORATION_ACTION;
    data: RemoveReplyOperationData;
    fileId: string | [];
    version: number;
  }

  export interface RemoveReplyOperationData {
    pageIndex: number;
    replyId: string;
  }

  export interface UpdateAnnotationCollaborationData {
    action: COLLABORATION_ACTION;
    data: UpdateAnnotationOperationData;
    version: number;
  }

  class UpdateAnnotationOperationData {
    annots: Object | [];
  }

  export interface UpdateAnnotContentCollaborationData {
    action: COLLABORATION_ACTION;
    data: UpdateAnnotContentOperationData;
    fileId: string | [];
    version: number;
  }

  export interface UpdateAnnotContentOperationData {
    annotId: string;
    content: string;
    pageIndex: number;
  }

  export interface UserCustomizeCollaborationData {
    action: string;
    data: Object;
    fileId: string | [];
    version: number;
  }

  class WebSocketCommunicator implements CollaborationCommunicator {
    connect(shareId: string): Promise<boolean>;
    disconnect(): Promise<boolean>;
    getLostData(
      shareId: string,
      fromVersion: number
    ): Promise<CollaborationData[]>;
    getSessionInfo(
      shareId: string
    ): Promise<CollaborationSessionInfo | undefined>;
    isConnected(): Promise<boolean>;
    send(shareId: string, data: string): Promise<void>;
    createSession(doc: PDFDoc): Promise<string>;
    destroy(): void;
    registerLostConnectionListener(receiver: () => void): void;
    registerMessageReceiver(receiver: (data: string) => void): void;
  }

  enum COLLABORATION_ACTION {
    CREATE_ANNOT,
    REMOVE_ANNOT,
    UPDATE_ANNOT,
    ADD_REPLY,
    REMOVE_REPLY,
    ADD_REVIEW_STATE,
    ADD_MARKED_STATE,
    UPDATE_ANNOT_CONTENT,
    PPO_REMOVE_PAGE,
    PPO_REMOVE_PAGES,
    PPO_INSERT_PAGE,
    PPO_ROTATE_PAGE,
    PPO_MOVE_PAGE,
    MOVE_ANNOTS_BETWEEN_PAGES,
    IMPORT_ANNOTATIONS_FILE,
  }

  class AnnotRender {
    active(): Promise<void>;
    getAnnot(): Annot;
    getComponent(): AnnotComponent;
    unActive(): Promise<void>;
  }

  class ViewerAnnotManager {
    getAnnotFlag(annot: Annot): AnnotFlag;
    registerMatchRule(
      matchRule: (
        pdfAnnot: Annot,
        annotComponent: AnnotComponent
      ) => undefined | (new <T extends AnnotComponent>() => Class<T>)
    ): Function;
    setViewerAnnotFlag(getAnnotFlagValue: (annot: Annot) => number): void;
    unRegisterMatchRule(
      matchRule: (
        pdfAnnot: Annot,
        annotComponent: AnnotComponent
      ) => undefined | (new <T extends AnnotComponent>() => Class<T>)
    ): void;
  }

  class PDFDocRender {
    disableDragToScroll(): void;
    enableDragToScroll(): void;
    getBoundingClientRects(): object[];
    getCurrentPageIndex(): number;
    getCurrentViewMode(): IViewMode | null;
    getHandlerDOM(): HTMLElement;
    getOffsetInfo(): Promise<{
      index: number;
      left: number;
      top: number;
      scale: number;
    }>;
    getPDFDoc(): PDFDoc;
    getRotation(): number;
    getScale(): Promise<number | 'fitWidth' | 'fitHeight'>;
    getUserPermission(): UserPermission;
    getViewMode(): IViewMode | undefined;
    getWatermarkConfig(): object | object[];
    goToPage(
      index: number,
      offset?: {
        x: number;
        y: number;
      },
      isPDFPoint?: boolean
    ): Promise<void>;
    renderPages(
      pageIndexes: number[],
      scale: number | 'fitWidth' | 'fitHeight'
    ): Promise<void>;
    setWatermarkConfig(
      watermarkConfig:
        | {
            type: 'text' | 'image';
            content: string;
            watermarkSettings?: {
              position?: Position;
              offsetX?: number;
              offsetY?: number;
              scaleX?: number;
              scaleY?: number;
              rotation?: number;
              opacity?: number;
            };
            watermarkTextProperties?: {
              font?: string;
              fontSize?: number;
              color?: string;
              fontStyle?: 'normal' | 'underline';
              lineSpace?: number;
              alignment?: 'left' | 'center' | 'right';
            };
          }
        | Array<{
            type: 'text' | 'image';
            content: string;
            watermarkSettings?: {
              position?: Position;
              offsetX?: number;
              offsetY?: number;
              scaleX?: number;
              scaleY?: number;
              rotation?: number;
              opacity?: number;
            };
            watermarkTextProperties?: {
              font?: string;
              fontSize?: number;
              color?: string;
              fontStyle?: 'normal' | 'underline';
              lineSpace?: number;
              alignment?: 'left' | 'center' | 'right';
            };
          }>
    ): void;
  }

  class PDFPageRender {
    getAnnotRender(name: string | number): AnnotRender | null;
    getHandlerDOM(): HTMLElement;
    getPDFDoc(): PDFDoc;
    getPDFPage(): Promise<PDFPage>;
    getScale(): number;
    getSignaturePDFRect(): void;
    getSnapshot(
      left: number,
      top: number,
      width: number,
      height: number
    ): Promise<Blob>;
    getWatermarkConfig(): object | object[];
    reverseDeviceRect(deviceRect: DeviceRect): Promise<PDFRect>;
    setWatermarkConfig(
      watermarkConfig: Record<string, any> | Array<Record<string, any>>
    ): void;
    transformPoint(options: {
      point: {
        x: number;
        y: number;
      };
      srcType: PagePointType;
      destType: PagePointType;
    }): Promise<{ x: number; y: number }>;
  }

  export interface HandStateHandlerConfig {
    enableTextSelectionTool: boolean;
  }

  class IStateHandler {
    constructor(pdfViewer: PDFViewer);

    destroyDocHandler(): void;
    destroyPageHandler(): void;
    docHandler(pdfDocRender: PDFDocRender): void;
    out(): void;
    pageHandler(pdfPageRender: PDFPageRender): void;
    static getStateName(): string;
    static setParams(params: object, pdfViewer: PDFViewer): void;
  }

  export interface StampStateHandlerParams {
    category: string;
    fileType: string;
    height: number;
    name: string;
    showUrl: string;
    url: string;
    width: number;
  }

  class StateHandlerManager {
    get(name: string): new <T extends IStateHandler>(pdfViewer: PDFViewer) => T;
    getCurrentStates(): new <T extends IStateHandler>(
      pdfViewer: PDFViewer
    ) => T;
    getStateHandlerConfig(
      stateHandlerName: STATE_HANDLER_NAMES
    ): StateHandlerConfig | undefined;
    mergeStateHandlerConfig(
      stateHandlerName: STATE_HANDLER_NAMES,
      stateHandlerConfig: Partial<StateHandlerConfig>
    ): void;
    register(
      StateHandler: new <T extends IStateHandler>(pdfViewer: PDFViewer) => T
    ): void;
    setStateHandlerConfig(
      stateHandlerName: STATE_HANDLER_NAMES,
      stateHandlerConfig: StateHandlerConfig
    ): void;
    switchTo(
      name: string,
      params: StampStateHandlerParams | Record<string, string> | undefined
    ): void;
  }
  type StateHandlerConfig = HandStateHandlerConfig;

  export interface ActionCallback {
    alert(options: AlertOptions): number;
  }

  export interface AlertOptions {
    cMsg: string;
    cTitle: string;
    nIcon: number;
    nType: number;
  }

  export interface BlendColorResolverOptions {
    callBuiltin: BlendColorResolver;
    combinePixelsOptions: CombinePixelsOptions;
    pos: Object;
    sourceColor: Color;
    targetColor: Color;
  }

  export interface CombinePixelsOptions {
    backgroundColor: number;
    blendColorResolver: BlendColorResolver;
    showDiffColor: boolean;
    sourceDiffColor: DiffColor;
    sourceOpacity: number;
    targetDiffColor: DiffColor;
    targetOpacity: number;
  }

  export interface ImageData {
    buffer: Optional<ArrayBuffer>;
    data: Optional<Uint8ClampedArray>;
    height: number;
    width: number;
  }

  export interface OverlayComparisonOptions {
    combinePixelsOptions: Partial<CombinePixelsOptions>;
    sourceBitmap: ImageData;
    targetBitmap: ImageData;
    transformation: Partial<OverlayComparisonTransformationOptions>;
  }

  class OverlayComparisonOptionsService {
    extractAllOptions(): CombinePixelsOptions;
    onChange(
      type: CombinePixelsOptionsKey,
      callback: OnOptionChangeCallback
    ): () => void;
    setBlendColorResolver(blendColorResolver: BlendColorResolver): void;
    setShowDiffColor(showDiffColor: boolean): void;
    setSourceDiffColor(sourceDiffColor: DiffColor): void;
    setSourceOpacity(sourceOpacity: number): void;
    setTargetDiffColor(targetDiffColor: DiffColor): void;
    setTargetOpacity(targetOpacity: number): void;
  }

  class OverlayComparisonService {
    compareImageData(options: OverlayComparisonOptions): HTMLCanvasElement;
  }

  export interface OverlayComparisonTransformationOptions {
    rotate: number;
    translateX: number;
    translateY: number;
  }

  enum DiffColor {
    RED,
    GREEN,
    BLUE,
    MAGENTA,
    YELLOW,
    CYAN,
  }

  type BlendColorResolver = (
    options: BlendColorResolverOptions
  ) => number | Color;
  type CombinePixelsOptionsKey = keyof CombinePixelsOptions;
  type OnOptionChangeCallback = (
    newValue: CombinePixelsOptions[CombinePixelsOptionsKey]
  ) => void;

  enum ANNOTATION_PERMISSION {
    fully,
    playable,
    adjustable,
    deletable,
    modifiable,
    attachmentDownloadable,
    replyable,
    editable,
  }

  enum MouseEventObjectType {
    annotation,
  }

  enum OPEN_FILE_TYPE {
    FROM_FILE,
    FROM_URL,
  }

  enum PagePointType {
    viewport,
    page,
    pdf,
  }

  enum SNAP_MODE {
    EndPoint,
    MidPoint,
    IntersectionPoint,
    NearestPoint,
  }

  enum STATE_HANDLER_NAMES {
    STATE_HANDLER_HAND,
    STATE_HANDLER_CREATE_CARET,
    STATE_HANDLER_CREATE_ARROW,
    STATE_HANDLER_CREATE_AREA_HIGHLIGHT,
    STATE_HANDLER_CREATE_CIRCLE,
    STATE_HANDLER_CREATE_FILE_ATTACHMENT,
    STATE_HANDLER_CREATE_HIGHLIGHT,
    STATE_HANDLER_CREATE_IMAGE,
    STATE_HANDLER_CREATE_LINK,
    STATE_HANDLER_CREATE_LINE,
    STATE_HANDLER_CREATE_DISTANCE,
    STATE_HANDLER_CREATE_PERIMETER,
    STATE_HANDLER_CREATE_AREA,
    STATE_HANDLER_CREATE_CIRCLE_AREA,
    STATE_HANDLER_CREATE_PENCIL,
    STATE_HANDLER_CREATE_POLYGON_CLOUD,
    STATE_HANDLER_CREATE_POLYGON,
    STATE_HANDLER_CREATE_POLYLINE,
    STATE_HANDLER_CREATE_REPLACE,
    STATE_HANDLER_CREATE_SQUARE,
    STATE_HANDLER_CREATE_SQUIGGLY,
    STATE_HANDLER_CREATE_STAMP,
    STATE_HANDLER_CREATE_STRIKE_OUT,
    STATE_HANDLER_CREATE_TEXT,
    STATE_HANDLER_CREATE_UNDERLINE,
    STATE_HANDLER_MARQUEE,
    STATE_HANDLER_ERASER,
    STATE_HANDLER_LOUPE,
    STATE_HANDLER_SELECT_TEXT_ANNOTATION,
    STATE_HANDLER_SELECT_TEXT_IMAGE,
    STATE_HANDLER_SELECT_ANNOTATION,
    STATE_HANDLER_CREATE_FREETEXT_BOX,
    STATE_HANDLER_CREATE_FREETEXT_CALLOUT,
    STATE_HANDLER_CREATE_FREETEXT_TYPEWRITER,
    STATE_HANDLER_CREATE_FIELD_TEXT,
    STATE_HANDLER_CREATE_FIELD_SIGNATURE,
    STATE_HANDLER_CREATE_FIELD_PUSH_BUTTON,
    STATE_HANDLER_CREATE_RADIO_BUTTON,
    STATE_HANDLER_SNAPSHOT_TOOL,
  }

  enum ViewerEvents {
    jrLicenseSuccess,
    beforeOpenFile,
    beforeLoadPDFDoc,
    openFileSuccess,
    openFileFailed,
    willCloseDocument,
    renderFileSuccess,
    renderFileFailed,
    beforeRenderPage,
    renderPageSuccess,
    zoomToSuccess,
    zoomToFailed,
    startChangeViewMode,
    changeViewModeSuccess,
    changeViewModeFailed,
    pageLayoutRedraw,
    copyTextSuccess,
    copyTextFailed,
    tapPage,
    tapAnnotation,
    pressPage,
    pressAnnotation,
    rightClickPage,
    rightClickAnnotation,
    doubleTapPage,
    doubleTapAnnotation,
    activeAnnotationBefore,
    activeAnnotation,
    activeAnnotationAfter,
    unActiveAnnotation,
    updateActiveAnnotation,
    removeActiveAnnotationBefore,
    removeActiveAnnotationSuccess,
    removeActiveAnnotationFailed,
    switchStateHandler,
    pageNumberChange,
    afterDocumentRotation,
    snapModeChanged,
    distanceAnnotCreationStart,
    updateDistanceAnnot,
    distanceAnnotCreationEnd,
    disableScroll,
    selectText,
    annotationPermissionChanged,
    mouseEnter,
    mouseLeave,
    focusOnControl,
    tapField,
    tapGraphicsObject,
  }

  class Activatable {
    isActive: boolean;
    active(): void;
    unActive(): void;
    protected doActive(): void;
    protected doDeactive(): void;
  }

  export interface AnnotTooltip {
    hide(): void;
    show(clientX: number, clientY: number): void;
  }

  export interface OpenFileParameter {
    file: Blob;
    options: object;
    type: OPEN_FILE_TYPE;
  }

  class PDFDocRendering {
    destroy(): void;
    rendered(): void;
    rendering(): void;
  }

  class PDFPageRendering {
    destroy(): void;
    rendered(): void;
    rendering(): void;
  }

  class PDFViewerRendering {
    rendered(): void;
    rendering(): void;
  }

  export interface PrintProgressBar {
    close(): void;
    show(): void;
    updateProgress(current: number, total: number): void;
  }

  class ScrollWrap extends Disposable {
    getHeight(): number;
    getScrollHost(): Window | Document | HTMLElement | Element;
    getScrollLeft(): number;
    getScrollOffsetLeft(): number;
    getScrollOffsetTop(): number;
    getScrollTop(): number;
    getScrollX(): number;
    getScrollY(): number;
    getWidth(): number;
    scrollBy(x: number, y: number): void;
    scrollTo(x: number, y: number): void;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
    destroy(): void;
  }

  class TextSelectionTool extends Disposable {
    copy(): Promise<void>;
    getSelectionInfo(): Promise<{
      text: string; // selected text
      page: PDFPage; // The page where the selected text is located
      rectArray: Array<{
        left: number;
        top: number;
        right: number;
        bottom: number;
        text: number;
      }>;
    }>;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
    destroy(): void;
  }

  class AnnotComponent extends Activatable {
    element: HTMLElement;
    isActive: boolean;
    getModel(): Annot;
    protected doActive(): void;
    protected doDeactive(): void;
    protected tapAnnot(): void;
    active(): void;
    unActive(): void;
  }

  class MarkupAnnotComponent extends AnnotComponent {
    element: HTMLElement;
    isActive: boolean;
    hideReplyDialog(): void;
    static getDefaultContextMenuConfig(): Record<string, any>;
    protected getContextMenuConfig(): void;
    protected hidePopup(): void;
    protected hidePropertiesDialog(): void;
    protected onDoubleTap(e: Object): boolean;
    protected showContextMenu(): void;
    protected showPopup(): void;
    protected showPropertiesDialog(): void;
    protected showReplyDialog(): void;
    getModel(): Annot;
    protected doActive(): void;
    protected doDeactive(): void;
    protected tapAnnot(): void;
    active(): void;
    unActive(): void;
  }

  abstract class AbstractPDFTextToSpeechSynthesis
    extends PDFTextToSpeechSynthesisTemplate
    implements PDFTextToSpeechSynthesis
  {
    status: PDFTextToSpeechSynthesisStatus;
    static extend(
      implementation: PDFTextToSpeechSynthesisTemplate
    ): PDFTextToSpeechSynthesis;
    pause(): void;
    play(
      utterances: IterableIterator<Promise<PDFTextToSpeechUtterance>>,
      options: ReadAloudOptions | undefined
    ): void;
    resume(): void;
    stop(): void;
    updateOptions(options: Partial<ReadAloudOptions>): void;
    protected doPause(): void;
    protected doResume(): void;
    protected doStop(): void;
    protected init(): void;
    protected onCurrentPlayingOptionsUpdated(): void;
    protected speakText(
      text: string,
      options: ReadAloudOptions | undefined
    ): Promise<void>;
  }

  export interface PDFTextToSpeechSynthesis {
    status: PDFTextToSpeechSynthesisStatus;
    pause(): void;
    play(
      utterances: IterableIterator<Promise<PDFTextToSpeechUtterance>>,
      options: ReadAloudOptions | undefined
    ): void;
    resume(): void;
    stop(): void;
    updateOptions(options: Partial<ReadAloudOptions>): void;
  }

  class PDFTextToSpeechSynthesisTemplate {
    protected doPause(): void;
    protected doResume(): void;
    protected doStop(): void;
    protected init(): void;
    protected onCurrentPlayingOptionsUpdated(): void;
    protected speakText(
      text: string,
      options: ReadAloudOptions | undefined
    ): Promise<void>;
  }

  export interface PDFTextToSpeechUtterance {
    pageIndex: number;
    rect: PDFRect;
    text: string;
  }

  export interface ReadAloudOptions {
    external: Record<string, any>;
    lang: string;
    pitch: number;
    rate: number;
    voice: string | SpeechSynthesisVoice;
    volume: number;
  }

  class ReadAloudService {
    onReadPageEnd(callback: (pageIndex: number) => void): () => void;
    onReadPageStart(callback: (pageIndex: number) => void): () => void;
    onStatusChange(
      callback: (status: PDFTextToSpeechSynthesisStatus) => void
    ): () => void;
    pause(): void;
    readPages(
      pageIndexes: number[],
      options: Partial<ReadAloudOptions>
    ): Promise<void>;
    readText(
      info: ReadAloudTextInformation,
      options: Partial<ReadAloudOptions>
    ): Promise<void>;
    resume(): void;
    setRate(rate: number): void;
    setSpeechSynthesis(speechSynthesis: PDFTextToSpeechSynthesis): void;
    setVolume(volume: number): void;
    status(): void;
    stop(): void;
    supported(): boolean;
    updatePlayingOptions(options: Partial<ReadAloudOptions>): boolean;
  }

  export interface ReadAloudTextInformation {
    pageIndex: number;
    rect: PDFRect;
    text: string;
  }

  enum PDFTextToSpeechSynthesisStatus {
    playing,
    paused,
    stopped,
  }

  export interface CreateAnnotationService extends Disposable {
    prepare(pageRender: PDFPageRender): void;
  }

  class CreateFreeTextCalloutService
    extends Disposable
    implements CreateAnnotationService
  {
    complete(): Promise<Annot[]>;
    prepare(pageRender: PDFPageRender): void;
    start(point: DevicePoint): void;
    update(point: DevicePoint, options?: Record<string, any>): void;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
    destroy(): void;
  }

  class IContextMenu {
    destroy(): void;
    disable(): void;
    enable(): void;
    getCurrentTarget(): any;
    setCurrentTarget(target: any): void;
    showAt(pageX: number, pageY: number): boolean;
  }

  class IFloatingTooltip extends Disposable {
    destroy(): void;
    disable(): void;
    enable(): void;
    hide(): void;
    showAt(
      pageX: number,
      pageY: number,
      text: string,
      rects: Array<{ left: number; right: number; top: number; bottom: number }>
    ): void;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class IViewerUI {
    alert(message: string): Promise<void>;
    confirm(message: string): Promise<void>;
    createContextMenu(
      key: any,
      anchor: HTMLElement,
      config: {
        selector: string;
        items: Array<{ nameI18nKey: string }>;
      }
    ): IContextMenu | undefined;
    createTextSelectionTooltip(pageRender: PDFPageRender): IFloatingTooltip;
    destroy(): void;
    loading(coverOn: HTMLElement): Function;
    prompt(
      defaultValue: string,
      message: string,
      title: string
    ): Promise<string>;
    promptPassword(
      defaultValue: string,
      message: string,
      title: string
    ): Promise<string>;
  }

  class TinyViewerUI extends IViewerUI {
    alert(message: string): Promise<void>;
    confirm(message: string): Promise<void>;
    createContextMenu(
      key: any,
      anchor: HTMLElement,
      config: {
        selector: string;
        items: Array<{ nameI18nKey: string }>;
      }
    ): IContextMenu | undefined;
    createTextSelectionTooltip(pageRender: PDFPageRender): IFloatingTooltip;
    destroy(): void;
    loading(coverOn: HTMLElement): Function;
    prompt(
      defaultValue: string,
      message: string,
      title: string
    ): Promise<string>;
    promptPassword(
      defaultValue: string,
      message: string,
      title: string
    ): Promise<string>;
  }

  class IViewMode {
    constructor(docRender: PDFDocRender);

    getCurrentPageIndex(): number;
    getFitHeight(index: number): number | Promise<number>;
    getFitWidth(index: number): number | Promise<number>;
    getNextPageIndex(): number;
    getPrevPageIndex(): number;
    getVisibleIndexes(): number[];
    into(pageContainer: HTMLElement, pageDOMs: Array<HTMLElement>): void;
    jumpToPage(
      index: number,
      offset: {
        x: number;
        y: number;
      }
    ): void;
    out(): void;
    renderViewMode(
      pageRender: PDFPageRender,
      scale: number,
      rotate: number,
      width: number,
      height: number
    ): void;
    static getName(): string;
  }

  class ViewModeManager {
    get(name: string): new <T extends IViewMode>(pdfViewer: PDFViewer) => T;
    getAll(): object;
    getCurrentViewMode(): new <T extends IViewMode>(pdfViewer: PDFViewer) => T;
    register(
      ViewMode: IViewMode
    ): new <T extends IViewMode>(pdfViewer: PDFViewer) => T;
    set(): void;
    switchTo(name: string): void;
  }

  const isDesktop: boolean;
  const isMobile: boolean;
  const isTablet: boolean;

  class LoggerFactory {
    static setLogLevel(level: string): void;
    static toggleLogger(logOff: boolean): void;
  }

  enum Log_Levels {
    LEVEL_DEBUG,
    LEVEL_INFO,
    LEVEL_WARN,
    LEVEL_ERROR,
  }

  class ActivationGroup {
    add(): void;
    clear(): void;
    contains(): boolean;
    remove(): void;
  }

  class AnnotationAuthorityManager extends Disposable {
    getPermission(annot: Annot): Promise<AnnotationPermission>;
    setAnnotPermissionCallback(
      getAnnotPermissionsCallback: GetAnnotPermissionsCallback
    ): void;
    subscribe(
      annot: Annot,
      callback: (permission: AnnotationPermission, annot: Annot) => void
    ): () => void;
    update(annot: Annot): Promise<void>;
    updateAll(): Promise<void>;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
    destroy(): void;
  }

  class AnnotationPermission {
    has(permissionType: ANNOTATION_PERMISSION | string): boolean;
    ignorable(): boolean;
    isAdjustable(): boolean;
    isAttachmentDownloadable(): boolean;
    isDeletable(): boolean;
    isEditable(): boolean;
    isModifiable(): boolean;
    isPlayable(): boolean;
    isRedactionApplicable(): boolean;
    isReplyable(): boolean;
  }

  class Disposable {
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
    destroy(): void;
  }

  class DivScrollWrap extends ScrollWrap {
    static create(
      wrapperElement: HTMLElement
    ): new (viewerRender: any, scrollHost: HTMLElement) => DivScrollWrap;
    getHeight(): number;
    getScrollHost(): Window | Document | HTMLElement | Element;
    getScrollLeft(): number;
    getScrollOffsetLeft(): number;
    getScrollOffsetTop(): number;
    getScrollTop(): number;
    getScrollX(): number;
    getScrollY(): number;
    getWidth(): number;
    scrollBy(x: number, y: number): void;
    scrollTo(x: number, y: number): void;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
    destroy(): void;
  }

  class PDFViewer extends Disposable {
    constructor(options: {
      jr: {
        licenseKey?: string;
        licenseSN?: string;
        l?: string;
        workerPath?: string;
        enginePath?: string;
        fontPath?: string;
        readBlock?: number;
        brotli?: {
          core?: boolean;
        };
      };
      preloadJR?: boolean;
      libPath?: string;
      minScale?: number;
      maxScale?: number;
      defaultScale?: number | string;
      scaleFrequency?: number;
      tileSize?: number;
      tileCache?: boolean;
      getTileSize?: Function;
      annotRenderingMode?: object;
      i18n?: typeof i18next;
      i18nOptions?: {
        initOption?: object;
        path?: string;
      };
      eventEmitter?: EventEmitter;
      Viewmodes?: Array<new (pdfDocRender: PDFDocRender) => IViewMode>;
      defaultViewMode?: string;
      defaultAnnotConfig?: Function;
      customs?: {
        closeDocBefore?: Function;
        closeDocAfter?: Function;
        getDocPermissions?: Function;
        getAdditionalPerm?: Function;
        getAnnotPermissions?: Function;
        ScrollWrap?: new (...args: any[]) => ScrollWrap;
        PDFViewerRendering?: PDFViewerRendering;
        PDFDocRendering?: PDFDocRendering;
        PDFPageRendering?: PDFPageRendering;
        AnnotTooltip?: AnnotTooltip;
        beforeRenderPDFDoc?: (pdfDoc: PDFDoc) => Promise<void>;
      };
      StateHandlers?: IStateHandler[];
      enableShortcutKey?: boolean;
      noJSFrame?: boolean;
      showCommentList?: boolean;
      showAnnotTooltip?: boolean;
      showFormFieldTooltip?: boolean;
      collaboration?: {
        enable?: boolean;
        communicator?: CollaborationCommunicator;
        continueToConnect?: (retryTimes: number, shareId: string) => boolean;
      };
      viewerUI?: IViewerUI;
      snapshotServer?: SnapshotServer;
      showMeasurementInfoPanel?: boolean;
    });

    element: HTMLElement;
    i18n: typeof i18next;
    activateAnnotation(options: Object): void;
    activateElement(element: Activatable): void;
    addAnnotationIcon(icon: {
      fileType?: string;
      url?: string;
      annotType?: string;
      category?: string;
      name?: string;
      width?: number;
      height?: number;
    }): Promise<void>;
    addFontMaps(
      fontMaps: Array<object>,
      fontMap: {
        name: string;
        style: number;
        charset: number;
      }
    ): void;
    close(before?: Function, after?: Function): Promise<void>;
    collaborate(
      action: string | COLLABORATION_ACTION,
      data:
        | Function
        | Object
        | AddReplyOperationData
        | AddReviewStateOperationData
        | CreateAnnotationOperationData
        | PPOInsertPageOperationData
        | PPOMovePageOperationData
        | PPORemovePageOperationData
        | PPORotatePageOperationData
        | RemoveAnnotationOperationData
        | RemoveReplyOperationData
        | UpdateAnnotationOperationData
        | UpdateAnnotContentOperationData
        | ImportAnnotationsFileCollaborationData
        | AddMarkedStateCollaborationData
    ): void;
    compareDocuments(
      baseDocId: string,
      otherDocId: string,
      params: {
        basePageRange: ComparePageRange;
        otherPageRange: ComparePageRange;
        baseFileName?: string;
        otherFileName?: string;
        resultFileName?: string;
        options?: {
          textOnly?: boolean;
          detectPage?: boolean;
          compareTable?: boolean;
          markingColor?: MarkingColorValues;
          lineThickness?: LineThicknessValues;
          opacity?: OpacityValues;
        };
      },
      onprogress: (currentRate: number) => void
    ): Promise<PDFDoc>;
    convertClientCoordToPDFCoord(
      clientX: number,
      clientY: number
    ): Promise<{
      index: number;
      left: number;
      top: number;
      scale: number;
      rotation: number;
    }>;
    convertImageToPDFDoc(
      file: File | Blob | ArrayBuffer,
      url: string,
      title: string,
      author: string,
      options?: object,
      pdfEngine?: any
    ): Promise<PDFDoc>;
    copyAnnots(annots: Array<Annot>): object[];
    copySnapshot(dataURL: string): void;
    createNewDoc(
      title: string,
      author: string,
      pageSize?: { height: number; width: number },
      options?: {
        isRenderOnDocLoaded?: boolean;
      },
      pdfEngine?: any
    ): Promise<PDFDoc>;
    deactivateElement(element: Activatable): void;
    getAllActivatedElements(): Activatable[];
    getAnnotAuthorityManager(): AnnotationAuthorityManager;
    getAnnotManager(): ViewerAnnotManager;
    getAnnotRender(
      pageIndex: number,
      name: string | number
    ): AnnotRender | null;
    getCurrentPDFDoc(): PDFDoc | null;
    getDefaultAnnotConfig(): (type: string, intent: string) => object;
    getEnableJS(): boolean;
    getEventEmitter(): EventEmitter;
    getFormHighlightColor(): { color: number; colorRequired: number };
    getInkSignList(type: string): object[];
    getOverlayComparisonOptionsService(): OverlayComparisonOptionsService;
    getOverlayComparisonService(): OverlayComparisonService;
    getPDFDocFromImageFile(): void;
    getPDFDocRender(): PDFDocRender | null;
    getPDFPageRender(index: number): PDFPageRender | null;
    getReadAloudService(): ReadAloudService;
    getRotation(): number;
    getScrollWrap(): ScrollWrap;
    getSnapMode(stateHandlerName: string): SNAP_MODE[];
    getStateHandlerManager(): StateHandlerManager;
    getViewModeManager(): ViewModeManager;
    highlightForm(highlight: boolean): void;
    init(selector: string | HTMLElement): void;
    initAnnotationIcons(icons: {
      url: string;
      fileType: string;
      width: number;
      height: number;
    }): Promise<void>;
    isShortcutKeyEnabled(): boolean;
    killFocus(): Promise<boolean>;
    loadPDFDocByFile(
      file: File | Blob | ArrayBuffer | TypedArray | DataView,
      options: {
        password?: string;
        encryptPassword?: string;
        fileName?: string;
        readBlock?: number;
        errorHandler?: (
          doc: PDFDoc,
          options: object,
          error: any | undefined,
          retry: (options: object) => Promise<PDFDoc | undefined>
        ) => Promise<PDFDoc | undefined>;
        drm?: {
          isEncryptMetadata?: boolean;
          subFilter?: string;
          cipher?: number;
          keyLength?: number;
          isOwner?: boolean;
          userPermissions?: number;
          fileId?: string;
          initialKey?: string;
        };
        fileOpen?: {
          encryptKey?: string[];
          cipher?: Cipher_Type[];
        };
        jwt?: Function;
      }
    ): Promise<PDFDoc | undefined>;
    loadPDFDocByHttpRangeRequest(
      request: {
        range: {
          url: string;
          type?: number;
          user?: number;
          password?: number;
          headers?: object;
          chunkSize?: number;
          extendOptions?: string;
        };
        size?: number;
      },
      options: {
        password?: string;
        encryptPassword?: string;
        fileName?: string;
        readBlock?: number;
        errorHandler?: (
          doc: PDFDoc,
          options: object,
          error: any | undefined,
          retry: (options: object) => Promise<PDFDoc | undefined>
        ) => Promise<PDFDoc | undefined>;
        drm?: {
          isEncryptMetadata?: boolean;
          subFilter?: string;
          cipher?: number;
          keyLength?: number;
          isOwner?: boolean;
          userPermissions?: number;
          fileId?: string;
          initialKey?: string;
        };
        fileOpen?: {
          encryptKey?: string[];
          cipher?: Cipher_Type[];
        };
        jwt?: Function;
      }
    ): Promise<PDFDoc | undefined>;
    offShortcutKey(shortcut: string, handler?: Function | object): void;
    onShortcutKey(
      shortcut: string,
      handler: Function | object,
      preventDefaultImplementation?: boolean
    ): void;
    openFileByShareId(shareId: string): Promise<PDFDoc>;
    openPDFByFile(
      file: File | Blob | ArrayBuffer | TypedArray | DataView,
      options?: {
        isRenderOnDocLoaded?: boolean;
        beforeRenderPDFDoc?: (pdfDoc: PDFDoc) => Promise<void>;
        password?: string;
        encryptPassword?: string;
        fileName?: string;
        readBlock?: number;
        annotsJson?: Record<string, any>;
        fdf?: {
          file?: File | Blob | ArrayBuffer | TypedArray | DataView;
          type?: number;
        };
        drm?: {
          isEncryptMetadata?: boolean;
          subFilter?: string;
          cipher?: number;
          keyLength?: number;
          isOwner?: boolean;
          userPermissions?: number;
          fileId?: string;
          initialKey?: string;
        };
        fileOpen?: {
          encryptKey?: string[];
          cipher?: Cipher_Type[];
        };
        jwt?: Function;
      }
    ): Promise<PDFDoc>;
    openPDFByHttpRangeRequest(
      request: {
        range: {
          url: string;
          type?: number;
          user?: number;
          password?: number;
          headers?: object;
          chunkSize?: number;
          extendOptions?: string;
        };
        size?: number;
      },
      options?: {
        isRenderOnDocLoaded?: boolean;
        beforeRenderPDFDoc?: (pdfDoc: PDFDoc) => Promise<void>;
        password?: string;
        encryptPassword?: string;
        fileName?: string;
        readBlock?: number;
        annotsJson?: object;
        fdf?: {
          file?: File | Blob | ArrayBuffer | TypedArray | DataView;
          type?: number;
        };
        drm?: {
          isEncryptMetadata?: boolean;
          subFilter?: string;
          cipher?: number;
          keyLength?: number;
          isOwner?: boolean;
          userPermissions?: number;
          fileId?: string;
          initialKey?: string;
        };
        fileOpen?: {
          encryptKey?: number[];
          cipher?: string[];
        };
        jwt?: Function;
      }
    ): Promise<PDFDoc>;
    openPDFById(
      id: string,
      options: {
        isRenderOnDocLoaded?: boolean;
        password?: string;
        fileName?: string;
        jwt?: Function;
      }
    ): Promise<PDFDoc>;
    pasteAnnots(datas: object[]): Promise<Array<Annot>>;
    print(
      options: {
        pages: Array<
          | number
          | {
              pageIndex: number;
              rect?: { x: number; y: number; width: number; height: number };
            }
        >;
        printType: string[];
        progress: PrintProgressBar | boolean;
        quality: number;
        showHeaderFooter: boolean;
      },
      callback: (
        data:
          | { state: 'start' }
          | {
              state: 'progress';
              pageIndex: number;
              total: number;
              imageURI: string;
            }
          | { state: 'end'; result: { [pageIndex: number]: string } }
      ) => void
    ): Promise<void>;
    printCurrentView(): Promise<void>;
    printEx(
      options: {
        type: number;
        pageRange: string;
        progress: PrintProgressBar | boolean;
      },
      callback: (
        data:
          | { state: 'start' }
          | { state: 'progress'; progress: number }
          | { state: 'end' }
      ) => void
    ): Promise<void>;
    redraw(force?: boolean): Promise<void>;
    registerCollabDataHandler(
      action: string | (() => CollaborationDataHandler<CollaborationData>),
      handler: (
        data: CollaborationData,
        handlerObj: CollaborationDataHandler<CollaborationData>
      ) => Promise<void>
    ): void;
    registerSignatureHandler(
      filter: string,
      subfilter: string,
      handler: {
        sign?: string;
        verify?: string;
      }
    ): void;
    removeAnnotationIcon(
      type: string,
      category: string,
      name: string
    ): Promise<void>;
    renderDoc(pdfDoc: PDFDoc, scale: number | string): Promise<boolean>;
    reopenPDFDoc(
      pdfDoc: PDFDoc,
      options?: {
        isRenderOnDocLoaded?: boolean;
        beforeRenderPDFDoc?: (pdfDoc: PDFDoc) => Promise<void>;
        password?: string;
        encryptPassword?: string;
        fileName?: string;
        annotsJson?: object;
        fdf?: {
          file?: File | Blob | ArrayBuffer | TypedArray | DataView;
          type?: number;
        };
        jwt?: Function;
        drm?: {
          isEncryptMetadata?: boolean;
          subFilter?: string;
          cipher?: number;
          keyLength?: number;
          isOwner?: boolean;
          userPermissions?: number;
          fileId?: string;
          initialKey?: string;
        };
        fileOpen?: {
          encryptKey?: number[];
          cipher?: string[];
        };
      }
    ): Promise<PDFDoc>;
    rotateTo(
      degree: number,
      options?: {
        pageIndex: number;
        baseX: number;
        baseY: number;
      }
    ): Promise<void>;
    setActionCallback(
      ActionCallbackClass: new (app: any) => ActionCallback
    ): void;
    setAutoCalculateFieldsFlag(autoCalculate: boolean): void;
    setDefaultAnnotConfig(fn: (type: string, intent: string) => object): void;
    setDefaultPrintSetting(printSetting?: {
      showHeaderFooter?: boolean;
      quality?: number;
    }): void;
    setDocReadColors(colors: object): void;
    setEnableJS(enable: boolean): void;
    setEnableShortcutKey(enable: boolean): void;
    setEraserSize(width: number): void;
    setFormatOfDynamicStamp(sperator: string, timeFormat: string): void;
    setFormCreationContinuously(isContinuous: boolean): void;
    setFormFieldFocusRectangleVisible(isVisible: boolean): void;
    setFormHighlightColor(color: number, requiredColor?: number): void;
    setInkSignList(inkSignList: object[]): void;
    setJRFontMap(fontMaps: FontMap[]): void;
    setPencilDrawingTimeOut(millseconds: number): void;
    setSnapMode(stateHandlerName: string, mode: SNAP_MODE): void;
    setUserName(userName: string): Promise<void>;
    takeSnapshot(
      pageIndex: number,
      left: number,
      top: number,
      width: number,
      height: number
    ): Promise<Blob>;
    uploadImage(blob: Blob): Promise<string>;
    zoomAtPosition(
      scale: number,
      fixedPosition: {
        pageIndex?: number;
        x: number;
        y: number;
      }
    ): Promise<void>;
    zoomTo(
      scale: number | 'fitWidth' | 'fitHeight',
      position?: {
        pageIndex: number;
        x: number;
        y: number;
      }
    ): Promise<void>;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
    destroy(): void;
  }

  class SnapshotServer {
    constructor(
      render: (responseText: string) => string,
      payloadFieldName: string,
      origin: string,
      uploadSnapshotAPIPath: string,
      method?: string
    );

    uploadImage(blob: Blob): Promise<string>;
  }

  class UserPermission {
    constructor(permissions: number);

    checkAnnotForm(): number;
    checkAssemble(): number;
    checkCannotModifyAny(): boolean;
    checkCannotModifyExcludeAssemble(): boolean;
    checkExtract(): number;
    checkExtractAccess(): number;
    checkFillForm(): number;
    checkModify(): number;
    checkPrint(): number;
    checkPrintHigh(): number;
    getValue(): number;
    or(permissions: number): UserPermission;
    putCannotModifyAny(): UserPermission;
    putCannotModifyExcludeAssemble(): UserPermission;
  }
  type GetAnnotPermissionsCallback = (
    annot: Annot
  ) => Promise<string[] | null | undefined>;

  type CustomScrollWrap = DivScrollWrap;
  const CustomScrollWrap: typeof DivScrollWrap;

  class ButtonComponent extends Component {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    setIconCls(iconCls: string): void;
    setText(newText: string): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class ContextMenuComponent extends LayerComponent {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    showAt(x: number, y: number): void;
    close(): void;
    open(appendTo: HTMLElement | ContainerComponent): void;
    show(appendTo?: HTMLElement | ContainerComponent): void;
    append(child: Component | string, fragments?: UIFragmentOptions[]): void;
    childAt(index: number): Component;
    children(): Component[];
    empty(): void;
    first(): Component;
    indexOf(child: Component): number;
    insert(
      child: Component | string | Node,
      index: number,
      fragments: UIFragmentOptions[]
    ): void;
    insertAll(children: Component[], index: number): void;
    last(): Component;
    prepend(child: Component | string, fragments: UIFragmentOptions[]): void;
    removeChild(child: Component): void;
    size(): number;
    protected doInsert(component: Component, index: number): void;
    protected doInsertAll(children: Component[], index: number): void;
    protected getContainerElement(): HTMLElement;
    protected rerenderChildren(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class ContextMenuItemComponent extends ButtonComponent {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    setIconCls(iconCls: string): void;
    setText(newText: string): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class DropdownButtonComponent extends Component {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class DropdownComponent extends ContainerComponent {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    getEditValue(): number | string;
    select(child: Component): void;
    setEditValue(value: string | number): void;
    setIconCls(iconCls: string): void;
    setText(text: string): void;
    unselect(): void;
    append(child: Component | string, fragments?: UIFragmentOptions[]): void;
    childAt(index: number): Component;
    children(): Component[];
    empty(): void;
    first(): Component;
    indexOf(child: Component): number;
    insert(
      child: Component | string | Node,
      index: number,
      fragments: UIFragmentOptions[]
    ): void;
    insertAll(children: Component[], index: number): void;
    last(): Component;
    prepend(child: Component | string, fragments: UIFragmentOptions[]): void;
    removeChild(child: Component): void;
    size(): number;
    protected doInsert(component: Component, index: number): void;
    protected doInsertAll(children: Component[], index: number): void;
    protected getContainerElement(): HTMLElement;
    protected rerenderChildren(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class DropdownItemComponent extends ContainerComponent {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    append(child: Component | string, fragments?: UIFragmentOptions[]): void;
    childAt(index: number): Component;
    children(): Component[];
    empty(): void;
    first(): Component;
    indexOf(child: Component): number;
    insert(
      child: Component | string | Node,
      index: number,
      fragments: UIFragmentOptions[]
    ): void;
    insertAll(children: Component[], index: number): void;
    last(): Component;
    prepend(child: Component | string, fragments: UIFragmentOptions[]): void;
    removeChild(child: Component): void;
    size(): number;
    protected doInsert(component: Component, index: number): void;
    protected doInsertAll(children: Component[], index: number): void;
    protected getContainerElement(): HTMLElement;
    protected rerenderChildren(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class FileSelectorComponent extends ButtonComponent {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    setIconCls(iconCls: string): void;
    setText(newText: string): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class FormFieldComponent extends Component {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    getFieldName(): string;
    getValue(): any;
    setValue(newValue: any): void;
    protected getDOMValue(): string;
    protected triggerChangeEvent(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class FormGroupComponent extends ContainerComponent {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    setDelimiter(delimiter?: string): void;
    setDescription(description: string): void;
    setDirection(direction?: 'ltr' | 'rtl' | 'ttb'): void;
    setLabel(label: string): void;
    append(child: Component | string, fragments?: UIFragmentOptions[]): void;
    childAt(index: number): Component;
    children(): Component[];
    empty(): void;
    first(): Component;
    indexOf(child: Component): number;
    insert(
      child: Component | string | Node,
      index: number,
      fragments: UIFragmentOptions[]
    ): void;
    insertAll(children: Component[], index: number): void;
    last(): Component;
    prepend(child: Component | string, fragments: UIFragmentOptions[]): void;
    removeChild(child: Component): void;
    size(): number;
    protected doInsert(component: Component, index: number): void;
    protected doInsertAll(children: Component[], index: number): void;
    protected getContainerElement(): HTMLElement;
    protected rerenderChildren(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class GroupComponent extends ContainerComponent {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    setRetainCount(retainCount: number): void;
    setShrinkTitle(title: string): void;
    append(child: Component | string, fragments?: UIFragmentOptions[]): void;
    childAt(index: number): Component;
    children(): Component[];
    empty(): void;
    first(): Component;
    indexOf(child: Component): number;
    insert(
      child: Component | string | Node,
      index: number,
      fragments: UIFragmentOptions[]
    ): void;
    insertAll(children: Component[], index: number): void;
    last(): Component;
    prepend(child: Component | string, fragments: UIFragmentOptions[]): void;
    removeChild(child: Component): void;
    size(): number;
    protected doInsert(component: Component, index: number): void;
    protected doInsertAll(children: Component[], index: number): void;
    protected getContainerElement(): HTMLElement;
    protected rerenderChildren(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class GroupListComponent extends ContainerComponent {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    append(child: Component | string, fragments?: UIFragmentOptions[]): void;
    childAt(index: number): Component;
    children(): Component[];
    empty(): void;
    first(): Component;
    indexOf(child: Component): number;
    insert(
      child: Component | string | Node,
      index: number,
      fragments: UIFragmentOptions[]
    ): void;
    insertAll(children: Component[], index: number): void;
    last(): Component;
    prepend(child: Component | string, fragments: UIFragmentOptions[]): void;
    removeChild(child: Component): void;
    size(): number;
    protected doInsert(component: Component, index: number): void;
    protected doInsertAll(children: Component[], index: number): void;
    protected getContainerElement(): HTMLElement;
    protected rerenderChildren(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class GTabComponent extends Component {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    close(): void;
    getTabBodyComponent(): Promise<ContainerComponent>;
    open(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class InlineColorPickerComponent extends FormFieldComponent {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    getFieldName(): string;
    getValue(): any;
    setValue(newValue: any): void;
    protected getDOMValue(): string;
    protected triggerChangeEvent(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class LayerComponent extends ContainerComponent {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    close(): void;
    open(appendTo: HTMLElement | ContainerComponent): void;
    show(appendTo?: HTMLElement | ContainerComponent): void;
    append(child: Component | string, fragments?: UIFragmentOptions[]): void;
    childAt(index: number): Component;
    children(): Component[];
    empty(): void;
    first(): Component;
    indexOf(child: Component): number;
    insert(
      child: Component | string | Node,
      index: number,
      fragments: UIFragmentOptions[]
    ): void;
    insertAll(children: Component[], index: number): void;
    last(): Component;
    prepend(child: Component | string, fragments: UIFragmentOptions[]): void;
    removeChild(child: Component): void;
    size(): number;
    protected doInsert(component: Component, index: number): void;
    protected doInsertAll(children: Component[], index: number): void;
    protected getContainerElement(): HTMLElement;
    protected rerenderChildren(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class LayerHeaderComponent extends ContainerComponent {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    setTitle(title: string): void;
    append(child: Component | string, fragments?: UIFragmentOptions[]): void;
    childAt(index: number): Component;
    children(): Component[];
    empty(): void;
    first(): Component;
    indexOf(child: Component): number;
    insert(
      child: Component | string | Node,
      index: number,
      fragments: UIFragmentOptions[]
    ): void;
    insertAll(children: Component[], index: number): void;
    last(): Component;
    prepend(child: Component | string, fragments: UIFragmentOptions[]): void;
    removeChild(child: Component): void;
    size(): number;
    protected doInsert(component: Component, index: number): void;
    protected doInsertAll(children: Component[], index: number): void;
    protected getContainerElement(): HTMLElement;
    protected rerenderChildren(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class LayerToolbarComponent extends ContainerComponent {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    append(child: Component | string, fragments?: UIFragmentOptions[]): void;
    childAt(index: number): Component;
    children(): Component[];
    empty(): void;
    first(): Component;
    indexOf(child: Component): number;
    insert(
      child: Component | string | Node,
      index: number,
      fragments: UIFragmentOptions[]
    ): void;
    insertAll(children: Component[], index: number): void;
    last(): Component;
    prepend(child: Component | string, fragments: UIFragmentOptions[]): void;
    removeChild(child: Component): void;
    size(): number;
    protected doInsert(component: Component, index: number): void;
    protected doInsertAll(children: Component[], index: number): void;
    protected getContainerElement(): HTMLElement;
    protected rerenderChildren(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class LayerViewComponent extends ContainerComponent {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    append(child: Component | string, fragments?: UIFragmentOptions[]): void;
    childAt(index: number): Component;
    children(): Component[];
    empty(): void;
    first(): Component;
    indexOf(child: Component): number;
    insert(
      child: Component | string | Node,
      index: number,
      fragments: UIFragmentOptions[]
    ): void;
    insertAll(children: Component[], index: number): void;
    last(): Component;
    prepend(child: Component | string, fragments: UIFragmentOptions[]): void;
    removeChild(child: Component): void;
    size(): number;
    protected doInsert(component: Component, index: number): void;
    protected doInsertAll(children: Component[], index: number): void;
    protected getContainerElement(): HTMLElement;
    protected rerenderChildren(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class NumberComponent extends FormFieldComponent {
    max: number;
    min: number;
    prefix: string;
    step: number;
    suffix: string;
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    getFieldName(): string;
    getValue(): any;
    setValue(newValue: any): void;
    protected getDOMValue(): string;
    protected triggerChangeEvent(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class OptionGroupComponent extends ContainerComponent {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    append(child: Component | string, fragments?: UIFragmentOptions[]): void;
    childAt(index: number): Component;
    children(): Component[];
    empty(): void;
    first(): Component;
    indexOf(child: Component): number;
    insert(
      child: Component | string | Node,
      index: number,
      fragments: UIFragmentOptions[]
    ): void;
    insertAll(children: Component[], index: number): void;
    last(): Component;
    prepend(child: Component | string, fragments: UIFragmentOptions[]): void;
    removeChild(child: Component): void;
    size(): number;
    protected doInsert(component: Component, index: number): void;
    protected doInsertAll(children: Component[], index: number): void;
    protected getContainerElement(): HTMLElement;
    protected rerenderChildren(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class PaddleComponent extends ContainerComponent {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    append(child: Component | string, fragments?: UIFragmentOptions[]): void;
    childAt(index: number): Component;
    children(): Component[];
    empty(): void;
    first(): Component;
    indexOf(child: Component): number;
    insert(
      child: Component | string | Node,
      index: number,
      fragments: UIFragmentOptions[]
    ): void;
    insertAll(children: Component[], index: number): void;
    last(): Component;
    prepend(child: Component | string, fragments: UIFragmentOptions[]): void;
    removeChild(child: Component): void;
    size(): number;
    protected doInsert(component: Component, index: number): void;
    protected doInsertAll(children: Component[], index: number): void;
    protected getContainerElement(): HTMLElement;
    protected rerenderChildren(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class SidebarComponent extends ContainerComponent {
    status: string;
    static STATUS_COLLAPSED: string;
    static STATUS_COLLAPSED_TOTALLY: string;
    static STATUS_EXPANDED: string;
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    collapse(): void;
    collapseTotally(): void;
    expand(): void;
    isCollapsed(): boolean;
    append(child: Component | string, fragments?: UIFragmentOptions[]): void;
    childAt(index: number): Component;
    children(): Component[];
    empty(): void;
    first(): Component;
    indexOf(child: Component): number;
    insert(
      child: Component | string | Node,
      index: number,
      fragments: UIFragmentOptions[]
    ): void;
    insertAll(children: Component[], index: number): void;
    last(): Component;
    prepend(child: Component | string, fragments: UIFragmentOptions[]): void;
    removeChild(child: Component): void;
    size(): number;
    protected doInsert(component: Component, index: number): void;
    protected doInsertAll(children: Component[], index: number): void;
    protected getContainerElement(): HTMLElement;
    protected rerenderChildren(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class SlotComponent extends ContainerComponent {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    append(child: Component | string, fragments?: UIFragmentOptions[]): void;
    childAt(index: number): Component;
    children(): Component[];
    empty(): void;
    first(): Component;
    indexOf(child: Component): number;
    insert(
      child: Component | string | Node,
      index: number,
      fragments: UIFragmentOptions[]
    ): void;
    insertAll(children: Component[], index: number): void;
    last(): Component;
    prepend(child: Component | string, fragments: UIFragmentOptions[]): void;
    removeChild(child: Component): void;
    size(): number;
    protected doInsert(component: Component, index: number): void;
    protected doInsertAll(children: Component[], index: number): void;
    protected getContainerElement(): HTMLElement;
    protected rerenderChildren(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class TabItemComponent extends ContainerComponent {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    append(child: Component | string, fragments?: UIFragmentOptions[]): void;
    childAt(index: number): Component;
    children(): Component[];
    empty(): void;
    first(): Component;
    indexOf(child: Component): number;
    insert(
      child: Component | string | Node,
      index: number,
      fragments: UIFragmentOptions[]
    ): void;
    insertAll(children: Component[], index: number): void;
    last(): Component;
    prepend(child: Component | string, fragments: UIFragmentOptions[]): void;
    removeChild(child: Component): void;
    size(): number;
    protected doInsert(component: Component, index: number): void;
    protected doInsertAll(children: Component[], index: number): void;
    protected getContainerElement(): HTMLElement;
    protected rerenderChildren(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class TabsComponent extends ContainerComponent {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    append(child: Component | string, fragments?: UIFragmentOptions[]): void;
    childAt(index: number): Component;
    children(): Component[];
    empty(): void;
    first(): Component;
    indexOf(child: Component): number;
    insert(
      child: Component | string | Node,
      index: number,
      fragments: UIFragmentOptions[]
    ): void;
    insertAll(children: Component[], index: number): void;
    last(): Component;
    prepend(child: Component | string, fragments: UIFragmentOptions[]): void;
    removeChild(child: Component): void;
    size(): number;
    protected doInsert(component: Component, index: number): void;
    protected doInsertAll(children: Component[], index: number): void;
    protected getContainerElement(): HTMLElement;
    protected rerenderChildren(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class TextComponent extends Component {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    setText(text: string): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class ToolbarComponent extends ContainerComponent {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    append(child: Component | string, fragments?: UIFragmentOptions[]): void;
    childAt(index: number): Component;
    children(): Component[];
    empty(): void;
    first(): Component;
    indexOf(child: Component): number;
    insert(
      child: Component | string | Node,
      index: number,
      fragments: UIFragmentOptions[]
    ): void;
    insertAll(children: Component[], index: number): void;
    last(): Component;
    prepend(child: Component | string, fragments: UIFragmentOptions[]): void;
    removeChild(child: Component): void;
    size(): number;
    protected doInsert(component: Component, index: number): void;
    protected doInsertAll(children: Component[], index: number): void;
    protected getContainerElement(): HTMLElement;
    protected rerenderChildren(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class TooltipLayerComponent extends LayerComponent {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    getCurrentSelectionTool(): TextSelectionTool | undefined;
    showAt(x: number, y: number, appendTo: string | HTMLElement): void;
    close(): void;
    open(appendTo: HTMLElement | ContainerComponent): void;
    show(appendTo?: HTMLElement | ContainerComponent): void;
    append(child: Component | string, fragments?: UIFragmentOptions[]): void;
    childAt(index: number): Component;
    children(): Component[];
    empty(): void;
    first(): Component;
    indexOf(child: Component): number;
    insert(
      child: Component | string | Node,
      index: number,
      fragments: UIFragmentOptions[]
    ): void;
    insertAll(children: Component[], index: number): void;
    last(): Component;
    prepend(child: Component | string, fragments: UIFragmentOptions[]): void;
    removeChild(child: Component): void;
    size(): number;
    protected doInsert(component: Component, index: number): void;
    protected doInsertAll(children: Component[], index: number): void;
    protected getContainerElement(): HTMLElement;
    protected rerenderChildren(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class CommentCardComponent extends CommentListCardComponent {
    menuComponent: DropdownComponent;
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    clearReplyEditor(): void;
    focusOnReplyEditor(): void;
    setModifyTime(datetime: Date): void;
    getTitleElement(): HTMLElement;
    getTimeElement(): HTMLElement;
    getToolsElement(): HTMLElement;
    applyState(): void;
    deselect(): void;
    select(): void;
    switchToEdit(): void;
    switchToView(): void;
    append(child: Component | string, fragments?: UIFragmentOptions[]): void;
    childAt(index: number): Component;
    children(): Component[];
    empty(): void;
    first(): Component;
    indexOf(child: Component): number;
    insert(
      child: Component | string | Node,
      index: number,
      fragments: UIFragmentOptions[]
    ): void;
    insertAll(children: Component[], index: number): void;
    last(): Component;
    prepend(child: Component | string, fragments: UIFragmentOptions[]): void;
    removeChild(child: Component): void;
    size(): number;
    protected doInsert(component: Component, index: number): void;
    protected doInsertAll(children: Component[], index: number): void;
    protected getContainerElement(): HTMLElement;
    protected rerenderChildren(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class CommentListCardComponent extends ContainerComponent {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    applyState(): void;
    deselect(): void;
    select(): void;
    switchToEdit(): void;
    switchToView(): void;
    append(child: Component | string, fragments?: UIFragmentOptions[]): void;
    childAt(index: number): Component;
    children(): Component[];
    empty(): void;
    first(): Component;
    indexOf(child: Component): number;
    insert(
      child: Component | string | Node,
      index: number,
      fragments: UIFragmentOptions[]
    ): void;
    insertAll(children: Component[], index: number): void;
    last(): Component;
    prepend(child: Component | string, fragments: UIFragmentOptions[]): void;
    removeChild(child: Component): void;
    size(): number;
    protected doInsert(component: Component, index: number): void;
    protected doInsertAll(children: Component[], index: number): void;
    protected getContainerElement(): HTMLElement;
    protected rerenderChildren(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class ReplyCardComponent extends CommentListCardComponent {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    getTimeElement(): HTMLElement;
    getTitleElement(): HTMLElement;
    getToolsElement(): HTMLElement;
    setContent(content: string): void;
    setTime(time: number | Date): void;
    setTitle(title: string): void;
    applyState(): void;
    deselect(): void;
    select(): void;
    switchToEdit(): void;
    switchToView(): void;
    append(child: Component | string, fragments?: UIFragmentOptions[]): void;
    childAt(index: number): Component;
    children(): Component[];
    empty(): void;
    first(): Component;
    indexOf(child: Component): number;
    insert(
      child: Component | string | Node,
      index: number,
      fragments: UIFragmentOptions[]
    ): void;
    insertAll(children: Component[], index: number): void;
    last(): Component;
    prepend(child: Component | string, fragments: UIFragmentOptions[]): void;
    removeChild(child: Component): void;
    size(): number;
    protected doInsert(component: Component, index: number): void;
    protected doInsertAll(children: Component[], index: number): void;
    protected getContainerElement(): HTMLElement;
    protected rerenderChildren(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  export interface ButtonComponentOptions extends ComponentOptions {
    iconCls?: string;
    text?: string;
  }

  export interface ComponentOptions {
    active?: boolean;
    canBeDisabled?: boolean;
    cls?: string;
    disabled?: boolean;
    visible?: boolean;
  }

  export interface DropdownComponentOptions extends ComponentOptions {
    iconCls?: string;
    text?: string;
  }

  export interface FormFieldComponentOptions extends ComponentOptions {
    fieldName?: string;
  }

  export interface FragmentComponentOptions extends ComponentOptions {
    attrs?: object;
    target?: string;
  }

  export interface GroupComponentOptions extends ComponentOptions {
    retainCount?: number;
    shrinkTitle?: string;
  }

  export interface LayerComponentOptions extends ComponentOptions {
    appendTo?: string | HTMLElement;
    backdrop?: boolean;
    modal?: boolean;
  }

  export interface LayerHeaderComponentOptions extends ComponentOptions {
    iconCls?: string;
    title?: string;
  }

  export interface NumberComponentOptions extends FormFieldComponentOptions {
    max?: number;
    min?: number;
    prefix?: string;
    step?: number;
    suffix?: string;
  }

  export interface PreConfiguredComponent {
    config?: Or<FragmentComponentOptions, FragmentComponentOptions[]>;
    template: string;
  }

  export interface SeniorComponentSuperclassOptions {
    fragments?: UIFragmentOptions | [];
    template?: string;
  }

  export interface SidebarPanelComponentOptions extends ComponentOptions {
    iconCls?: string;
    title?: string;
  }

  export interface TabItemComponentOptions extends ComponentOptions {
    title?: string;
  }

  export interface UIFragmentOptions {
    action?: FRAGMENT_ACTION;
    config?: Or<FragmentComponentOptions, FragmentComponentOptions[]>;
    target: Or<string, string[]>;
    template?: string;
  }

  class Component {
    constructor(
      options: ComponentOptions,
      module: UIXModule,
      localizer: Object
    );

    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class ContainerComponent extends Component {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    append(child: Component | string, fragments?: UIFragmentOptions[]): void;
    childAt(index: number): Component;
    children(): Component[];
    empty(): void;
    first(): Component;
    indexOf(child: Component): number;
    insert(
      child: Component | string | Node,
      index: number,
      fragments: UIFragmentOptions[]
    ): void;
    insertAll(children: Component[], index: number): void;
    last(): Component;
    prepend(child: Component | string, fragments: UIFragmentOptions[]): void;
    removeChild(child: Component): void;
    size(): number;
    protected doInsert(component: Component, index: number): void;
    protected doInsertAll(children: Component[], index: number): void;
    protected getContainerElement(): HTMLElement;
    protected rerenderChildren(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    show(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class LoadingComponent extends LayerComponent {
    canBeDisabled: boolean;
    constroller: Controller;
    disabled: boolean;
    element: HTMLElement;
    isActive: boolean;
    isVisible: boolean;
    name: string;
    parent: ContainerComponent;
    close(): void;
    open(appendTo: HTMLElement | ContainerComponent): void;
    show(appendTo?: HTMLElement | ContainerComponent): void;
    append(child: Component | string, fragments?: UIFragmentOptions[]): void;
    childAt(index: number): Component;
    children(): Component[];
    empty(): void;
    first(): Component;
    indexOf(child: Component): number;
    insert(
      child: Component | string | Node,
      index: number,
      fragments: UIFragmentOptions[]
    ): void;
    insertAll(children: Component[], index: number): void;
    last(): Component;
    prepend(child: Component | string, fragments: UIFragmentOptions[]): void;
    removeChild(child: Component): void;
    size(): number;
    protected doInsert(component: Component, index: number): void;
    protected doInsertAll(children: Component[], index: number): void;
    protected getContainerElement(): HTMLElement;
    protected rerenderChildren(): void;
    active(): void;
    addDestroyHook(...hooks: Array<() => void>): void;
    after(component: Component | string, fragments: UIFragmentOptions[]): void;
    attachEventToElement(
      element: EventTarget,
      types: string,
      listener: EventListenerOrEventListenerObject,
      options: AddEventListenerOptions
    ): void;
    before(component: Component | string, fragments: UIFragmentOptions[]): void;
    deactive(): void;
    destroy(): void;
    disable(): boolean;
    enable(): boolean;
    findClosestComponent(
      callback: (component: Component) => boolean
    ): Component | undefined;
    getClosestComponentByName(name: string): Component | undefined;
    getClosestComponentByType(type: string): Component | undefined;
    getComponentByName(): Component;
    getPDFUI(): PDFUI;
    getRoot(): Component;
    hide(): void;
    index(): number;
    isContainer(): boolean;
    isStateKept(): boolean;
    keepState(): void;
    localize(): Promise<void>;
    nextSiblings(): Component;
    off(eventName: string, listener?: { (...args: any[]): void }): void;
    on(eventName: string, listener: () => void): void;
    once(eventName: string, listener: () => void): void;
    postlink(): void;
    prelink(): void;
    previousSiblings(): Component;
    querySelector(selector: string): Component | undefined;
    querySelectorAll(selector: string): Component[];
    remove(): void;
    removeElement(): void;
    revokeKeepState(): void;
    trigger(eventName: string, data: any[]): void;
    static extend(name: string, def: object, statics: object): void;
    static getName(): string;
    protected createDOMElement(): HTMLElement;
    protected doActive(): void;
    protected doDeactive(): void;
    protected doDestroy(): void;
    protected doDisable(): void;
    protected doEnable(): void;
    protected doHidden(): void;
    protected doShown(): void;
    protected mounted(): void;
    protected render(): void;
  }

  class AddImageController extends Controller {
    protected component: Component;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class AnnotOperationController extends Controller {
    protected component: Component;
    protected usable(annot: Annot): Promise<boolean> | boolean;
    protected visibility(annot: Annot): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class ApplyAllRedactController extends AnnotOperationController {
    protected component: Component;
    protected usable(annot: Annot): Promise<boolean> | boolean;
    protected visibility(annot: Annot): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class ApplyRedactController extends AnnotOperationController {
    protected component: Component;
    protected usable(annot: Annot): Promise<boolean> | boolean;
    protected visibility(annot: Annot): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CancelCreatingMeasurementController extends Controller {
    protected component: Component;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CompleteCreatingMeasurementController extends Controller {
    protected component: Component;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class ContinuousFacingPageModeController extends ViewModeController {
    protected component: Component;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class ContinuousPageModeController extends ViewModeController {
    protected component: Component;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class Controller extends Disposable {
    constructor(component: Component);

    protected component: Component;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CopyAnnotTextController extends AnnotOperationController {
    protected component: Component;
    protected visibility(annot: Annot): boolean;
    protected usable(annot: Annot): Promise<boolean> | boolean;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreateAreaController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreateAreaHighlightController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreateArrowController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreateCalloutController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreateCaretController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreateCircleAreaController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreateCircleController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreateDistanceController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreateFileAttachmentController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreateHighlightController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreateImageController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreateLineController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreateLinkController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreatePencilController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreatePerimeterController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreatePolygonCloudController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreatePolygonController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreatePolylineController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreateReplaceController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreateSquareController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreateSquigglyController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreateStrikeoutController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreateTextboxController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreateTextController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreateTypewriterController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class CreateUnderlineController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class DeleteAnnotController extends AnnotOperationController {
    protected component: Component;
    protected usable(annot: Annot): Promise<boolean> | boolean;
    protected visibility(annot: Annot): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class DownloadFileController extends Controller {
    protected component: Component;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class FacingPageModeController extends ViewModeController {
    protected component: Component;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class GotoFirstPageController extends Controller {
    protected component: Component;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class GotoLastPageController extends Controller {
    protected component: Component;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class GotoNextPageController extends Controller {
    protected component: Component;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class GotoPageController extends Controller {
    protected component: Component;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class GotoPrevPageController extends Controller {
    protected component: Component;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class HandController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class LoupeController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class MarqueeToolController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class MediaDownloadController extends AnnotOperationController {
    protected component: Component;
    protected usable(annot: Annot): Promise<boolean> | boolean;
    protected visibility(annot: Annot): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class MediaPauseController extends AnnotOperationController {
    protected component: Component;
    protected usable(annot: Annot): Promise<boolean> | boolean;
    protected visibility(annot: Annot): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class MediaPlayController extends AnnotOperationController {
    protected component: Component;
    protected usable(annot: Annot): Promise<boolean> | boolean;
    protected visibility(annot: Annot): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class OpenLocalFileController extends Controller {
    protected component: Component;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class OpenRemoteFileController extends Controller {
    protected component: Component;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class SelectTextAnnotationController extends StatefulController {
    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class ShowActionsController extends AnnotOperationController {
    protected component: Component;
    protected usable(annot: Annot): Promise<boolean> | boolean;
    protected visibility(annot: Annot): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class ShowAnnotFormPropertiesController extends Controller {
    protected component: Component;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class ShowAnnotPropertiesController extends Controller {
    protected component: Component;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class ShowAnnotReplyController extends AnnotOperationController {
    protected component: Component;
    protected usable(annot: Annot): Promise<boolean> | boolean;
    protected visibility(annot: Annot): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class ShowRedactPlaceDialogController extends AnnotOperationController {
    protected component: Component;
    protected usable(annot: Annot): Promise<boolean> | boolean;
    protected visibility(annot: Annot): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class ShowSearchPanelController extends Controller {
    protected component: Component;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class SignPropertyController extends Controller {
    protected component: Component;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class SinglePageModeController extends ViewModeController {
    protected component: Component;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class StatefulController extends Controller {
    constructor(
      component: Component,
      ExpectedStateHandlerClass: string | (new () => IStateHandler)
    );

    protected component: Component;
    protected stateIn(): void;
    protected stateOut(): void;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class TotalPageTextController extends Controller {
    protected component: Component;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  class ViewModeController extends Controller {
    constructor(component: Component, viewModeName: string);

    protected component: Component;
    destroy(): void;
    getComponentByName(name: string): void;
    handle(): void;
    static extend(prototype: object, statics: object): void;
    static getName(): string;
    protected getPDFUI(): void;
    protected mounted(): void;
    protected postlink(): void;
    protected prelink(): void;
    protected static services(): Record<
      string,
      new <T>(...args: unknown[]) => T
    >;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
  }

  enum COMPONENT_EVENTS {
    DISABLE,
    ENABLE,
    ACTIVE,
    DEACTIVE,
    SHOWN,
    HIDDEN,
    DESTROYED,
    REMOVED,
    INSERTED,
    MOUNTED,
    CLOSED,
    EXPAND,
    RESIZESTART,
    RESIZE,
    COLLAPSE,
  }

  enum FRAGMENT_ACTION {
    BEFORE,
    AFTER,
    APPEND,
    PREPEND,
    INSERT,
    FILL,
    REPLACE,
    EXT,
    REMOVE,
  }

  enum Loading_Mode {
    fromFileObject,
    fromMemory,
  }

  const WEBPDF_VIEWER_COMPONENT_NAME = 'pdf-viewer';

  class AdaptiveAppearance extends Appearance {
    afterMounted(root: Component): void;
    beforeMounted(root: Component): void;
    static extend(prototype: object, statics?: object): Class<Appearance>;
    protected disableAll(): void;
    protected enableAll(): void;
    protected getDefaultFragments(): UIFragmentOptions[];
    protected getLayoutTemplate(): string;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
    destroy(): void;
  }

  class Appearance extends Disposable {
    afterMounted(root: Component): void;
    beforeMounted(root: Component): void;
    static extend(prototype: object, statics?: object): Class<Appearance>;
    protected disableAll(): void;
    protected enableAll(): void;
    protected getDefaultFragments(): UIFragmentOptions[];
    protected getLayoutTemplate(): string;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
    destroy(): void;
  }

  class MobileAppearance extends UIAppearance {
    afterMounted(root: Component): void;
    beforeMounted(root: Component): void;
    static extend(prototype: object, statics?: object): Class<Appearance>;
    protected disableAll(): void;
    protected enableAll(): void;
    protected getDefaultFragments(): UIFragmentOptions[];
    protected getLayoutTemplate(): string;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
    destroy(): void;
  }

  class RibbonAppearance extends UIAppearance {
    afterMounted(root: Component): void;
    beforeMounted(root: Component): void;
    static extend(prototype: object, statics?: object): Class<Appearance>;
    protected disableAll(): void;
    protected enableAll(): void;
    protected getDefaultFragments(): UIFragmentOptions[];
    protected getLayoutTemplate(): string;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
    destroy(): void;
  }

  class UIAppearance extends Appearance {
    afterMounted(root: Component): void;
    beforeMounted(root: Component): void;
    static extend(prototype: object, statics?: object): Class<Appearance>;
    protected disableAll(): void;
    protected enableAll(): void;
    protected getDefaultFragments(): UIFragmentOptions[];
    protected getLayoutTemplate(): string;
    addDestroyHook(hooks: Array<Disposable | Function>): Function;
    destroy(): void;
  }

  class Modular {
    module(name: string, deps?: Array<string | UIXModule>): UIXModule;
    root(): UIXModule;
  }

  class PDFUI extends (PDFViewer as unknown as PromisifyClass<
    PDFViewer,
    'destroy'
  >) {
    constructor(options: {
      viewerOptions: object;
      renderTo: HTMLElement | string;
      appearance?: new (pdfUI: PDFUI) => Appearance;
      addons?: string | Array<string | UIXAddon>;
      i18n?: {
        absolutePath?: string;
      };
      customs?: {
        getLoadingMode?: (fileOrUrl: File | string) => number;
        defaultStateHandler?: STATE_HANDLER_NAMES;
        handlerParams?: object;
        defaultExportCommentsFormat?: string;
        scalingValues?: number[];
        autoDownloadAfterSign?: boolean;
        getSignedDocument?: (pdfBlob: Blob) => Blob;
        loading?: (
          coverOn: HTMLElement,
          text: string,
          animation: boolean
        ) =>
          | string
          | Component
          | HTMLElement
          | Promise<string | Component | HTMLElement>;
      };
    });

    element: HTMLElement;
    i18n: typeof i18next;
    addCssFonts(fonts: string[]): void;
    addUIEventListener(
      type: string | string[] | { [type: string]: () => void },
      listener: () => void
    ): () => void;
    addViewerEventListener(
      type: string | string[] | { [type: string]: () => void },
      listener: () => void
    ): () => void;
    callAddonAPI(
      addonLibrary: string,
      action: string,
      args: any[]
    ): Promise<any>;
    changeLanguage(language: string): Promise<void>;
    destroy(): Promise<void>;
    getAllComponentsByName(name: string): Promise<Component[]>;
    getAnnotationIcons(
      annotType: string,
      onlyCustomized: boolean
    ): Promise<object>;
    getComponentByName(name: string): Promise<Component>;
    getCurrentLanguage(): string;
    getPDFViewer(): Promise<PDFViewer>;
    getRootComponent(): Promise<Component>;
    getSelectedTextInfo(): Promise<{
      page: PDFPage;
      rectArray: Array<{
        left: number;
        right: number;
        top: number;
        bottom: number;
      }>;
    }>;
    getStampService(): StampService;
    loading(
      coverOn?: HTMLElement | Component,
      text?: string,
      animation?: boolean | string
    ): Promise<LoadingComponent>;
    openFormPropertyBoxAfterCreated(isOpen: boolean): void;
    registerSignatureFlowHandler(
      handler: (signField: PDFField) => Promise<object>,
      signField: PDFField,
      setting: {
        filter: string;
        subfilter: string;
        flag: number;
        signer: string;
        reason: string;
        email: string;
        image: string;
        distinguishName: string;
        location: string;
        text: string;
        defaultContentsLength: number;
        sign: (
          setting: object,
          plainBuffer: ArrayBuffer
        ) => Promise<ArrayBuffer>;
      }
    ): void;
    registerSignaturePropertyHandler(
      handler: (signatureInfo: object) => object
    ): void;
    registerSignHandler(handler: {
      filter: string;
      subfilter: string;
      signer: string;
      distinguishName: number;
      location: number;
      reason: number;
      defaultContentsLength: number;
      flag: Signature_Ap_Flags;
      sign: (
        signInfo: object,
        plainBuffer: ArrayBuffer
      ) => Promise<ArrayBuffer>;
      timeFormat: {
        format: string;
        timeZoneOptions: {
          separator: string;
          prefix: string;
          showSpace: boolean;
        };
      };
    }): void;
    removeUIEventListener(type: string | string[], listener: () => void): void;
    removeViewerEventListener(
      type: string | string[],
      listener: () => void
    ): Promise<void>;
    setDefaultMeasurementRatio(options: {
      userSpaceScaleValue: number;
      userSpaceUnit: string;
      realScaleValue: number;
      realUnit: string;
    }): void;
    setSnapshotInteractionClass(
      interactionClass: new (
        pdfViewer: PDFViewer,
        snapshot: Snapshot
      ) => SnapshotInteraction
    ): void;
    setVerifyHandler(
      handler: (
        field: PDFField,
        plainBuffer: Uint8Array,
        signedData: Uint8Array
      ) => Promise<number>
    ): void;
    waitForInitialization(): Promise<void>;
    static module(name: string, deps: Array<string | UIXModule>): UIXModule;
  }

  class SeniorComponentFactory {
    static createSuperClass: any;
  }

  export interface Snapshot {
    area: DeviceRect;
    data: Blob;
    pageRender: PDFPageRender;
  }

  class SnapshotInteraction {
    protected pdfViewer: PDFViewer;
    protected snapshot: Snapshot;
    onCancel(prepareData: string | Blob): void;
    onDownload(prepareData: string | Blob): void;
    onOk(prepareData: string | Blob): void;
    prepare(): void;
    protected copyToClipboard(): Promise<void>;
  }

  class UIXAddon {
    afterMounted(root: Component): void;
    beforeMounted(root: Component): void;
    destroy(): Promise<void> | void;
    fragments(): UIFragmentOptions[];
    getI18NResources(): object;
    getName(): string;
    init(pdfui: PDFUI): void;
    pdfViewerCreated(pdfviewer: PDFUI): void;
    protected receiveAction(actionName: string, args: any[]): void;
    protected static initOnLoad(): void;
  }

  class UIXModule {
    controller(name: string, controllerDef: object): UIXModule;
    getPreConfiguredComponent(name: string): PreConfiguredComponent;
    registerComponent(componentClass: Component): UIXModule;
    registerController(ControllerClass: Controller): UIXModule;
    registerPreConfiguredComponent(
      name: string,
      component: PreConfiguredComponent
    ): UIXModule;
  }

  class XViewerUI extends TinyViewerUI {
    alert(message: string, title?: string): Promise<void>;
    confirm(message: string, title?: string): Promise<void>;
    createContextMenu(
      owner: string | AnnotComponent,
      anchor: HTMLElement,
      config: {
        selector: string;
      }
    ): IContextMenu;
    prompt(
      defaultValue: string,
      message: string,
      title?: string
    ): Promise<string>;
    protected getAnnotsContextMenuName(owner: AnnotComponent): string;
    protected getContextMenuNameByOwner(
      owner: string | AnnotComponent
    ): string | undefined;
    createTextSelectionTooltip(pageRender: PDFPageRender): IFloatingTooltip;
    destroy(): void;
    loading(coverOn: HTMLElement): Function;
    promptPassword(
      defaultValue: string,
      message: string,
      title: string
    ): Promise<string>;
  }

  enum UIEvents {
    fullscreenchange,
    appendCommentListComment,
    appendCommentListReply,
    destroyCommentListComment,
    destroyCommentListReply,
    InkImageSelected,
    addContentSuccess,
    initializationCompleted,
    bookmarkSelected,
  }

  const modular: Modular;
}
