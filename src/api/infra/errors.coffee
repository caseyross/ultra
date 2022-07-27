import { Time } from '../../utils/index.js'

class AnyError extends Error
	constructor: (message) ->
		super(message)
		@.name = @.constructor.name

class ConnectionFailedError extends AnyError
	constructor: ({ cause }) ->
		super(cause.message)
class CredentialsRequiredError extends AnyError
	constructor: ({ message }) ->
		super(message)
class InvalidRequestError extends AnyError
	constructor: ({ code }) ->
		super("code #{code}")
		@.code = code
class LoginFailedError extends AnyError
	constructor: ({ reason }) ->
		super("reason: #{reason}")
		@.reason = reason
class RatelimitExceededError extends AnyError
	constructor: ({ waitMs }) ->
		super("wait #{Time.msToS(waitMs, { trunc: true })} seconds")
		@.waitMs = waitMs
class ResourceMovedError extends AnyError
	constructor: ({ code }) ->
		super("code #{code}")
		@.code = code
class ServerNotAvailableError extends AnyError
	constructor: ({ code }) ->
		super("code #{code}")
		@.code = code
class UnknownError extends AnyError
	constructor: ({ cause }) ->
		super(cause.message)

export default {

	AnyError,
	
	ConnectionFailedError,
	CredentialsRequiredError,
	InvalidRequestError,
	LoginFailedError,
	RatelimitExceededError,
	ResourceMovedError,
	ServerNotAvailableError,
	UnknownError

}